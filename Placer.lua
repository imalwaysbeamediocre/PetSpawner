
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

local isNotificationActive = false
local function notify(title, text, duration)
end

local petVisualPlacerEnabled = true    
local gui, toggleButton, unknownFolder, touchStartTime, touchStartPosition
local holdDuration = 3
local activePets, movementConnection = {}, nil

-- Global registry untuk semua pet handles untuk anti-collision
local petHandles = {}

-- Rotation values for Queen Bee RightWing
local wingRotationSystem = {
    LeftWing = {
        currentZ = 1,      -- mulai dari 1
        minZ = 1,          -- batas minimum
        maxZ = 150,        -- batas maksimum
        direction = 1,     -- 1 untuk naik (1→150), -1 untuk turun (150→1)
        speed = 33          -- kecepatan rotasi per frame
    },
    RightWing = {
    currentZ = -150,   -- mulai dari -150
    minZ = -150,       -- batas minimum -150
    maxZ = 1,          -- batas maksimum 1
    direction = 1,     -- 1 untuk naik (-150→1)
    speed = 33         -- kecepatan rotasi per frame
}
}
local wingRotationConnection

local dragonflyRotationSystem = {
    wings = {
        "LeftTopWing1", "LeftTopWing2", "LeftBottomWing1", "LeftBottomWing2", "LeftTopWingDetail", "LeftBottomWingDetail",
        "RightTopWing1", "RightTopWing2", "RightBottomWing1", "RightBottomWing2", "RightTopWingDetail", "RightBottomWingDetail"
    },
    currentZ = -50,        -- mulai dari -50 (bukan nil)
    initialZ = -50,        -- menyimpan Z rotation awal (bukan Y)
    minZ = -150,           -- batas minimum -150 (bukan maxY)
    maxZ = -50,            -- batas maksimum -50 (bukan initial)
    direction = -1,        -- -1 untuk turun (-50→-150), 1 untuk naik (-150→-50)
    speed = 25,            -- kecepatan rotasi per frame
    initialized = true     -- langsung set true karena sudah ada nilai default
}
local dragonflyRotationConnection

local function initializeDragonflyRotation(dragonflyModel)
    if dragonflyRotationSystem.initialized then return end
    
    -- Ambil Z rotation dari wing pertama yang ditemukan (bukan Y)
    for _, wingName in ipairs(dragonflyRotationSystem.wings) do
        local wing = dragonflyModel:FindFirstChild(wingName, true)
        if wing and wing:IsA("BasePart") then
            dragonflyRotationSystem.initialZ = wing.Rotation.Z -- Ambil Z, bukan Y
            dragonflyRotationSystem.currentZ = wing.Rotation.Z
            dragonflyRotationSystem.initialized = true
            
            break
        end
    end
end

-- Function untuk update Dragonfly wing rotation
local function updateDragonflyRotation()
    if not dragonflyRotationSystem.initialized then return end
    
    -- Update rotasi berdasarkan arah dan kecepatan
    dragonflyRotationSystem.currentZ = dragonflyRotationSystem.currentZ + (dragonflyRotationSystem.speed * dragonflyRotationSystem.direction)
    
    -- Check batas dan ubah arah
    if dragonflyRotationSystem.currentZ <= dragonflyRotationSystem.minZ then -- <= karena minZ adalah -150
        dragonflyRotationSystem.currentZ = dragonflyRotationSystem.minZ
        dragonflyRotationSystem.direction = 1 -- balik arah ke atas (-150 → -50)
    elseif dragonflyRotationSystem.currentZ >= dragonflyRotationSystem.maxZ then -- >= karena maxZ adalah -50
        dragonflyRotationSystem.currentZ = dragonflyRotationSystem.maxZ
        dragonflyRotationSystem.direction = -1 -- balik arah ke bawah (-50 → -150)
    end
    
    return dragonflyRotationSystem.currentZ
end

local PetMover = {}
PetMover.__index = PetMover

function PetMover.new(tool, petArea)
    local self = setmetatable({}, PetMover)
    self.tool = tool
    self.handle = tool:FindFirstChild("Handle")
    self.petArea = petArea
    if not self.handle then return nil end
    self.isActive = true
    self.isMoving = false
    self.currentTarget = nil
    self.idleTime = 0
    self.maxIdleTime = math.random(3, 8)
    self.moveSpeed = math.random(12, 20)
    self.lastPosition = self.handle.Position
    self.stuckTime = 0
    self.baseRotation = math.atan2(-self.handle.CFrame.LookVector.X, -self.handle.CFrame.LookVector.Z)
    self.currentLookDirection = Vector3.new(0, 0, -1)
    self.rotationSpeed = 3
    
    -- Fixed Y position untuk mencegah jatuh
    self.fixedY = self.handle.Position.Y
    
    self:setupPhysics()
    self:setupAntiCollision()
    self:getNewTarget()
    
    -- Daftarkan handle ke registry global
    table.insert(petHandles, self.handle)
    
    return self
end

function PetMover:setupPhysics()
    -- Hapus semua body objects yang ada
    for _, child in pairs(self.handle:GetChildren()) do
        if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or child:IsA("BodyAngularVelocity") or child:IsA("AlignOrientation") then
            child:Destroy()
        end
    end
    
    self.handle.Anchored = false
    self.handle.CanCollide = false
    
    -- Set collision untuk semua parts
    for _, part in pairs(self.tool:GetDescendants()) do
        if part:IsA("BasePart") then 
            part.CanCollide = false 
        end
    end
    
    -- BodyVelocity untuk movement horizontal
    self.bodyVelocity = Instance.new("BodyVelocity")
    self.bodyVelocity.MaxForce = Vector3.new(5000, 0, 5000) -- Tidak ada force di Y axis
    self.bodyVelocity.Velocity = Vector3.zero
    self.bodyVelocity.Parent = self.handle
    
    -- BodyPosition untuk fixed Y coordinate (anti-gravity)
    self.bodyPosition = Instance.new("BodyPosition")
    self.bodyPosition.MaxForce = Vector3.new(0, math.huge, 0) -- Hanya force di Y axis
    self.bodyPosition.Position = Vector3.new(0, self.fixedY, 0)
    self.bodyPosition.D = 2000 -- Damping untuk smooth movement
    self.bodyPosition.P = 10000 -- Power untuk maintain position
    self.bodyPosition.Parent = self.handle
    
    -- BodyAngularVelocity untuk rotasi
    self.bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    self.bodyAngularVelocity.MaxTorque = Vector3.new(0, 5000, 0)
    self.bodyAngularVelocity.AngularVelocity = Vector3.zero
    self.bodyAngularVelocity.Parent = self.handle
end

function PetMover:setupAntiCollision()
    -- Setup anti-collision dengan semua pet handles yang sudah ada
    for _, otherHandle in pairs(petHandles) do
        if otherHandle ~= self.handle and otherHandle.Parent then
            -- Buat NoCollisionConstraint antara pet ini dengan pet lain
            for _, myPart in pairs(self.tool:GetDescendants()) do
                if myPart:IsA("BasePart") then
                    for _, otherPart in pairs(otherHandle.Parent:GetDescendants()) do
                        if otherPart:IsA("BasePart") then
                            local noCollision = Instance.new("NoCollisionConstraint")
                            noCollision.Part0 = myPart
                            noCollision.Part1 = otherPart
                            noCollision.Parent = myPart
                        end
                    end
                end
            end
        end
    end
end

function PetMover:getNewTarget()
    if not self.petArea then return end
    local pos, size = self.petArea.Position, self.petArea.Size
    local padding = 4
    local minX, maxX = pos.X - size.X/2 + padding, pos.X + size.X/2 - padding
    local minZ, maxZ = pos.Z - size.Z/2 + padding, pos.Z + size.Z/2 - padding
    
    -- Target hanya menggunakan X dan Z, Y tetap fixed
    self.currentTarget = Vector3.new(
        minX + math.random() * (maxX - minX), 
        self.fixedY, -- Y tetap sama
        minZ + math.random() * (maxZ - minZ)
    )
    
    self.isMoving = true
    self.idleTime = 0
end

function PetMover:updateRotation(moveDirection)
    if not moveDirection or moveDirection.Magnitude < 0.1 then
        self.bodyAngularVelocity.AngularVelocity = Vector3.zero
        return
    end
    
    local targetYRotation = math.atan2(-moveDirection.X, -moveDirection.Z)
    local currentYRotation = math.atan2(-self.handle.CFrame.LookVector.X, -self.handle.CFrame.LookVector.Z)
    local rotationDifference = targetYRotation - currentYRotation
    
    rotationDifference = rotationDifference % (2 * math.pi)
    if rotationDifference > math.pi then 
        rotationDifference = rotationDifference - 2 * math.pi 
    end
    
    local rotationSpeed = math.clamp(rotationDifference * self.rotationSpeed, -5, 5)
    self.bodyAngularVelocity.AngularVelocity = Vector3.new(0, rotationSpeed, 0)
end

function PetMover:update(deltaTime)
    if not self.handle or not self.handle.Parent or not self.isActive then 
        return false 
    end
    
    local currentPos = self.handle.Position
    
    -- Update fixed Y position untuk BodyPosition
    self.bodyPosition.Position = Vector3.new(currentPos.X, self.fixedY, currentPos.Z)
    
    -- Check if stuck (hanya check X dan Z movement)
    local currentPos2D = Vector3.new(currentPos.X, 0, currentPos.Z)
    local lastPos2D = Vector3.new(self.lastPosition.X, 0, self.lastPosition.Z)
    local distanceMoved = (currentPos2D - lastPos2D).Magnitude
    
    if distanceMoved < 0.1 and self.isMoving then
        self.stuckTime = self.stuckTime + deltaTime
        if self.stuckTime > 3 then
            self:getNewTarget()
            self.stuckTime = 0
        end
    else
        self.stuckTime = 0
    end
    
    self.lastPosition = currentPos
    
    if self.isMoving and self.currentTarget then
        -- Hanya hitung distance di X dan Z axis
        local targetPos2D = Vector3.new(self.currentTarget.X, 0, self.currentTarget.Z)
        local currentPos2D = Vector3.new(currentPos.X, 0, currentPos.Z)
        local direction2D = targetPos2D - currentPos2D
        local distance2D = direction2D.Magnitude
        
        if distance2D > 3 then
            local moveDirection = direction2D.Unit
            -- Hanya set velocity untuk X dan Z, Y velocity = 0
            self.bodyVelocity.Velocity = Vector3.new(
                moveDirection.X * self.moveSpeed, 
                0, -- Y velocity selalu 0
                moveDirection.Z * self.moveSpeed
            )
            self:updateRotation(moveDirection)
        else
            -- Stop moving
            self.isMoving = false
            self.bodyVelocity.Velocity = Vector3.zero
            self.bodyAngularVelocity.AngularVelocity = Vector3.zero
            self.maxIdleTime = math.random(3, 8)
        end
    else
        -- Idle state
        self.idleTime = self.idleTime + deltaTime
        self.bodyVelocity.Velocity = Vector3.zero
        self.bodyAngularVelocity.AngularVelocity = Vector3.zero
        
        if self.idleTime >= self.maxIdleTime then
            self:getNewTarget()
            self.moveSpeed = math.random(12, 20)
        end
    end
    
    return true
end

function PetMover:destroy()
    -- Remove dari global registry
    for i, handle in ipairs(petHandles) do
        if handle == self.handle then
            table.remove(petHandles, i)
            break
        end
    end
    
    -- Destroy body objects
    if self.bodyVelocity then self.bodyVelocity:Destroy() end
    if self.bodyPosition then self.bodyPosition:Destroy() end
    if self.bodyAngularVelocity then self.bodyAngularVelocity:Destroy() end
    
    self.isActive = false
end

local function startMovementSystem()
    if movementConnection then movementConnection:Disconnect() end
    local lastTime = tick()
    movementConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        if deltaTime >= 0.05 then
            lastTime = currentTime
            for i = #activePets, 1, -1 do
                local petMover = activePets[i]
                local success, shouldKeep = pcall(petMover.update, petMover, deltaTime)
                if not success or not shouldKeep then
                    if petMover.destroy then petMover:destroy() end
                    table.remove(activePets, i)
                end
            end
        end
    end)
end

-- Function to handle Queen Bee RightWing rotation
local function updateWingRotation(wingData)
    -- Update rotasi berdasarkan arah dan kecepatan
    wingData.currentZ = wingData.currentZ + (wingData.speed * wingData.direction)
    
    -- Check batas dan ubah arah
    if wingData.currentZ >= wingData.maxZ then
        wingData.currentZ = wingData.maxZ
        wingData.direction = -1 -- balik arah ke bawah
    elseif wingData.currentZ <= wingData.minZ then
        wingData.currentZ = wingData.minZ
        wingData.direction = 1 -- balik arah ke atas
    end
    
    return wingData.currentZ
end

-- Fungsi sistem rotasi wing yang baru
local function startWingRotationSystem()
    if wingRotationConnection then wingRotationConnection:Disconnect() end
    wingRotationConnection = RunService.Heartbeat:Connect(function()
        if not unknownFolder then 
            
            return 
        end
        
        for _, tool in pairs(unknownFolder:GetChildren()) do
            if tool:IsA("Tool") then
                -- Handle Queen Bee
                local queenBee = tool:FindFirstChild("Queen Bee", true)
                if queenBee then
                    -- Handle LeftWing dan RightWing secara terpisah
                    for wingName, wingData in pairs(wingRotationSystem) do
                        local wing = queenBee:FindFirstChild(wingName, true)
                        if wing and wing:IsA("BasePart") then
                            -- Update rotasi untuk wing ini
                            local newZRotation = updateWingRotation(wingData)
                            
                            -- Apply rotasi baru
                            local success, result = pcall(function()
                                -- Pertahankan rotasi X dan Y yang asli, hanya ubah Z
                                local currentRotation = wing.Rotation
                                wing.Rotation = Vector3.new(
                                    currentRotation.X, -- pertahankan X
                                    currentRotation.Y, -- pertahankan Y  
                                    newZRotation       -- set Z rotasi baru
                                )
                            end)
                            
                            if not success then
                                
                            end
                        end
                    end
                end
                
                -- Handle Dragonfly
                local dragonfly = tool:FindFirstChild("Dragonfly", true)
if dragonfly then
    -- Inisialisasi jika belum (sekarang tidak diperlukan karena sudah initialized = true)
    if not dragonflyRotationSystem.initialized then
        initializeDragonflyRotation(dragonfly)
    end
    
    -- Update rotasi Z untuk semua wing (bukan Y)
    if dragonflyRotationSystem.initialized then
        local newZRotation = updateDragonflyRotation()
        
        -- Apply rotasi ke semua wing Dragonfly
        for _, wingName in ipairs(dragonflyRotationSystem.wings) do
            local wing = dragonfly:FindFirstChild(wingName, true)
            if wing and wing:IsA("BasePart") then
                local success, result = pcall(function()
                    -- Pertahankan rotasi X dan Y, hanya ubah Z (bukan Y)
                    local currentRotation = wing.Rotation
                    wing.Rotation = Vector3.new(
                        currentRotation.X, -- pertahankan X
                        currentRotation.Y, -- pertahankan Y
                        newZRotation       -- set Z rotasi baru (bukan Y)
                    )
                end)
                
                if not success then
                    
                end
            end
        end
    end
end
end
        end
    end)
end

-- Fungsi untuk mengatur kecepatan rotasi wing (opsional)
local function setWingSpeed(leftSpeed, rightSpeed)
    wingRotationSystem.LeftWing.speed = leftSpeed or wingRotationSystem.LeftWing.speed
    wingRotationSystem.RightWing.speed = rightSpeed or wingRotationSystem.RightWing.speed
end

-- Fungsi untuk mengatur range rotasi wing (opsional)
local function setWingRange(minZ, maxZ)
    wingRotationSystem.LeftWing.minZ = minZ or wingRotationSystem.LeftWing.minZ
    wingRotationSystem.LeftWing.maxZ = maxZ or wingRotationSystem.LeftWing.maxZ
    wingRotationSystem.RightWing.minZ = minZ or wingRotationSystem.RightWing.minZ
    wingRotationSystem.RightWing.maxZ = maxZ or wingRotationSystem.RightWing.maxZ
end

-- Fungsi untuk reset posisi wing ke default
local function resetWingRotations()
    wingRotationSystem.LeftWing.currentZ = wingRotationSystem.LeftWing.minZ
    wingRotationSystem.LeftWing.direction = 1
    wingRotationSystem.RightWing.currentZ = wingRotationSystem.RightWing.maxZ
    wingRotationSystem.RightWing.direction = -1
end

-- Fungsi untuk mendapatkan status rotasi wing (debugging)
local function getWingStatus()
    return {
        LeftWing = {
            current = wingRotationSystem.LeftWing.currentZ,
            direction = wingRotationSystem.LeftWing.direction > 0 and "UP" or "DOWN"
        },
        RightWing = {
            current = wingRotationSystem.RightWing.currentZ,
            direction = wingRotationSystem.RightWing.direction > 0 and "UP" or "DOWN"
        }
    }
end

local function createPetMovement(tool, petArea)
    local petMover = PetMover.new(tool, petArea)
    if not petMover then return nil end
    table.insert(activePets, petMover)
    if not movementConnection then startMovementSystem() end
    if not wingRotationConnection then startWingRotationSystem() end
    return petMover
end

local function findMyFarmAndPetArea()
    for _, farm in pairs(Workspace.Farm:GetChildren()) do
        if farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data") and farm.Important.Data:FindFirstChild("Owner") then
            local owner = farm.Important.Data.Owner.Value
            if owner == LocalPlayer.DisplayName or owner == LocalPlayer.Name then
                local petArea = farm:FindFirstChild("PetArea")
                return farm, petArea and petArea:IsA("BasePart") and petArea or nil
            end
        end
    end
    return nil, nil
end

local function getRandomPosition(myFarm)
    local canPlantParts = {}
    for _, part in pairs(myFarm:GetDescendants()) do
        if part.Name == "Can_Plant" and part:IsA("BasePart") then
            table.insert(canPlantParts, part)
        end
    end
    if #canPlantParts ~= 2 then
        notify("Pet Placer", "Exactly!", 5)
        return nil
    end
    local p1, p2 = canPlantParts[1], canPlantParts[2]
    local minX = math.min(p1.Position.X - p1.Size.X/2, p2.Position.X - p2.Size.X/2)
    local maxX = math.max(p1.Position.X + p1.Size.X/2, p2.Position.X + p2.Size.X/2)
    local minZ = math.min(p1.Position.Z - p1.Size.Z/2, p2.Position.Z - p2.Size.Z/2)
    local maxZ = math.max(p1.Position.Z + p2.Size.Z/2, p2.Position.Z + p2.Size.Z/2)
    local yPos = math.max(p1.Position.Y + p1.Size.Y/2, p2.Position.Y + p2.Size.Y/2) + 2
    return Vector3.new(math.random() * (maxX - minX) + minX, yPos, math.random() * (maxZ - minZ) + minZ)
end

local function setupPassthrough(tool)
    local function applyPassthrough(character)
        if not character then return end
        for _, petPart in pairs(tool:GetDescendants()) do
            if petPart:IsA("BasePart") then
                for _, charPart in pairs(character:GetChildren()) do
                    if charPart:IsA("BasePart") then
                        local noCollision = Instance.new("NoCollisionConstraint")
                        noCollision.Part0 = petPart
                        noCollision.Part1 = charPart
                        noCollision.Parent = petPart
                    end
                end
            end
        end
    end
    for _, player in pairs(Players:GetPlayers()) do
        applyPassthrough(player.Character)
        player.CharacterAdded:Connect(applyPassthrough)
    end
    Players.PlayerAdded:Connect(function(player)
        applyPassthrough(player.Character)
        player.CharacterAdded:Connect(applyPassthrough)
    end)
end

local function setupPetPhysics(tool, position)
    local handle = tool:FindFirstChild("Handle")
    if not handle then return false end
    
    handle.CFrame = CFrame.new(position)
    handle.Anchored = false
    handle.CanCollide = false
    
    -- Set collision untuk semua parts kecuali TopBaseplate
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") and part ~= Workspace:FindFirstChild("TopBaseplate") then
            part.CanCollide = false
        end
    end
    
    local topBaseplate = Workspace:FindFirstChild("TopBaseplate")
    if topBaseplate and topBaseplate:IsA("BasePart") then 
        topBaseplate.CanCollide = true 
    end
    
    setupPassthrough(tool)
    
    local myFarm, petArea = findMyFarmAndPetArea()
    if not petArea then return false end
    
    return createPetMovement(tool, petArea) and true or false
end

-- Variabel untuk mengatur delay placement
local PLACEMENT_DELAY = 0.9-- Delay dalam detik (bisa diubah sesuai kebutuhan)
local isPlacementInProgress = false

-- Fungsi untuk memastikan unknown folder ada
local function ensureUnknownFolder()
    if not unknownFolder or not unknownFolder.Parent then
        unknownFolder = Instance.new("Folder")
        unknownFolder.Name = "Unknown"
        unknownFolder.Parent = Workspace
        
    end
    return unknownFolder
end

-- Modified handlePetPlacement function dengan pengecekan alternatif
-- Function to apply 90° rotation to Dragonfly tool
local function applyDragonflyRotation(tool)
    -- Find dragonfly model in the tool
    local dragonflyModel = nil
    for _, descendant in pairs(tool:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == "Dragonfly" then
            dragonflyModel = descendant
            break
        end
    end
    
    if not dragonflyModel or not dragonflyModel.PrimaryPart then 
        return false -- Not a dragonfly tool or no PrimaryPart
    end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then 
        return false
    end
    
    -- Remove existing welds
    for _, weld in pairs(handle:GetChildren()) do
        if weld:IsA("Weld") or weld:IsA("WeldConstraint") then
            weld:Destroy()
        end
    end
    
    -- Apply 90° rotation (vertical rotation around Y-axis)
    local rotationRadians = math.rad(90)
    local offset = CFrame.new(0.3, -0.8, -0.1) -- Default offset from Dragonfly Rotator
    local rotation = CFrame.Angles(0, rotationRadians, 0) -- Y-axis rotation (vertical)
    local rotation2 = CFrame.Angles(0, 0, 0) -- No additional rotation
    
    -- Ensure pet parts are properly configured
    for _, part in pairs(dragonflyModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = false
        end
    end
    
    -- Apply positioning
    dragonflyModel.PrimaryPart.CFrame = handle.CFrame * offset * rotation * rotation2
    
    -- Create new weld
    local weld = Instance.new("Weld")
    weld.Part0 = handle
    weld.Part1 = dragonflyModel.PrimaryPart
    weld.C0 = CFrame.new()
    weld.C1 = offset * rotation * rotation2
    weld.Parent = handle
    
    
    return true
end

-- Modified handlePetPlacement function dengan rotasi dragonfly
local function handlePetPlacement(position)
    -- Cek apakah sedang dalam proses placement
    if isPlacementInProgress then
        notify("Pet Placer", "Please wait, placement in progress...", 2)
        return
    end
    
    local myFarm, petArea = findMyFarmAndPetArea()
    if not myFarm or not petArea then
        notify("Pet Placer", "Farm not found!", 5)
        return
    end
    
    local pos, size = petArea.Position, petArea.Size
    if position.X < pos.X - size.X/2 or position.X > pos.X + size.X/2 or
       position.Z < pos.Z - size.Z/2 or position.Z > pos.Z + size.Z/2 then
        notify("Pet Placer", "Place within farm area!", 5)
        return
    end
    
    -- Mencari tool yang sedang di-equip di character dengan atribut "PetDuped"
    local char = LocalPlayer.Character
    if not char then
        notify("Pet Placer", "Character not found!", 5)
        return
    end
    
    -- Ganti bagian pencarian tool di function handlePetPlacement
-- Dari baris sekitar 540-560, ganti bagian ini:

-- Mencari tool yang sedang di-equip di character dengan atribut "PetDuped" ATAU "ItemType" = "Pet"
local char = LocalPlayer.Character
if not char then
    notify("Pet Placer", "Character not found!", 5)
    return
end

local equippedTool = nil

-- Cari tool yang sedang di-equip di character dengan pengecekan alternatif
for _, tool in pairs(char:GetChildren()) do
    if tool:IsA("Tool") then
        -- Pengecekan pertama: attribute "PetDuped"
        local hasPetDuped = tool:GetAttribute("PetDuped")
        
        -- Pengecekan kedua: attribute "ItemType" dengan value "Pet"
        local itemType = tool:GetAttribute("ItemType")
        local isPetType = (itemType == "Pet")
        
        -- Jika salah satu kondisi terpenuhi, tool dianggap valid
        if hasPetDuped or isPetType then
            equippedTool = tool
            
            break
        end
    end
end

if not equippedTool then
    notify("Pet Placer", "Pet only can be placed on your garden", 5)
    return
end
    
    -- Set flag bahwa placement sedang dalam proses
    isPlacementInProgress = true
    
    -- Unequip tool dari character
    if equippedTool.Parent == char then 
        equippedTool.Parent = LocalPlayer:WaitForChild("Backpack")
    end
    
    -- Check if it's a Dragonfly and apply rotation
    local isDragonfly = false
    for _, descendant in pairs(equippedTool:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == "Dragonfly" then
            isDragonfly = true
            break
        end
    end
    
    if isDragonfly then
        notify("Pet Placer", "Dragonfly detected! Applying 90° rotation...", 2)
        
        -- Spawn coroutine untuk rotasi dragonfly
        task.spawn(function()
            -- Apply rotation
            local rotationSuccess = applyDragonflyRotation(equippedTool)
            if rotationSuccess then
                
            else
                
            end
            
            -- Wait 0.1 seconds as requested
            task.wait(0.1)
            
            -- Lanjutkan dengan placement normal
            local randomPos = getRandomPosition(myFarm)
            if not randomPos then 
                isPlacementInProgress = false
                return 
            end
            
            local topBaseplate = Workspace:FindFirstChild("TopBaseplate")
            if topBaseplate and topBaseplate:IsA("BasePart") then 
                topBaseplate.CanCollide = true 
            end
            
            -- Pastikan unknown folder ada
            ensureUnknownFolder()
            
            -- Pindahkan tool ke unknownFolder untuk placement
            if equippedTool and equippedTool.Parent then
                equippedTool.Parent = unknownFolder
                
                if setupPetPhysics(equippedTool, randomPos) then
                    notify("Pet Placer", "Dragonfly placed successfully with 90° rotation!", 3)
                else
                    notify("Pet Placer", "Failed to setup Dragonfly!", 5)
                end
            else
                notify("Pet Placer", "Dragonfly was destroyed or moved during rotation!", 5)
            end
            
            -- Reset flag placement
            isPlacementInProgress = false
        end)
    else
        -- Notifikasi bahwa placement dimulai dengan countdown (untuk non-dragonfly)
        notify("Pet Placer", "Placing pet in " .. PLACEMENT_DELAY .. " seconds...", PLACEMENT_DELAY)
        
        -- Spawn coroutine untuk delay placement
        task.spawn(function()
            -- Countdown visual (opsional)
            for i = PLACEMENT_DELAY, 1, -1 do
                if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("StatusLabel") then
                    gui.MainFrame.StatusLabel.Text = "Placing pet in " .. i .. "s..."
                end
                task.wait(1)
            end
            
            -- Reset status label
            if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("StatusLabel") then
                gui.MainFrame.StatusLabel.Text = "Status: " .. (petVisualPlacerEnabled and "Enabled" or "Disabled")
            end
            
            -- Lakukan placement setelah delay
            local randomPos = getRandomPosition(myFarm)
            if not randomPos then 
                isPlacementInProgress = false
                return 
            end
            
            local topBaseplate = Workspace:FindFirstChild("TopBaseplate")
            if topBaseplate and topBaseplate:IsA("BasePart") then 
                topBaseplate.CanCollide = true 
            end
            
            -- Pastikan unknown folder ada
            ensureUnknownFolder()
            
            -- Pindahkan tool ke unknownFolder untuk placement
            if equippedTool and equippedTool.Parent then
                equippedTool.Parent = unknownFolder
                
                if setupPetPhysics(equippedTool, randomPos) then
                    notify("Pet Placer", "Pet placed successfully!", 3)
                else
                    notify("Pet Placer", "Failed to setup pet!", 5)
                end
            else
                notify("Pet Placer", "Pet was destroyed or moved during delay!", 5)
            end
            
            -- Reset flag placement
            isPlacementInProgress = false
        end)
    end
end

-- Fungsi untuk mengubah delay placement (opsional)
local function setPlacementDelay(seconds)
    if type(seconds) == "number" and seconds >= 0 then
        PLACEMENT_DELAY = seconds
        notify("Pet Placer", "Placement delay set to " .. seconds .. " seconds", 3)
    else
        notify("Pet Placer", "Invalid delay value!", 3)
    end
end

-- Fungsi untuk mendapatkan delay saat ini (opsional)
local function getPlacementDelay()
    return PLACEMENT_DELAY
end

local function debugPetSystem()
    local debugInfo = {"=== PET SYSTEM DEBUG ===", "Movement: " .. (movementConnection and "ACTIVE" or "INACTIVE"), "Active Pets: " .. #activePets, "Pet Handles in Registry: " .. #petHandles}
    for i, petMover in ipairs(activePets) do
        if petMover and petMover.handle and petMover.handle.Parent then
            local pos, target, cframe = petMover.handle.Position, petMover.currentTarget, petMover.handle.CFrame
            local rotation = math.deg(math.atan2(-cframe.LookVector.X, -cframe.LookVector.Z))
            table.insert(debugInfo, string.format("Pet %d: Pos(%.1f,%.1f,%.1f) FixedY:%.1f Moving:%s Target:%s Rotation:%.1f°",
                i, pos.X, pos.Y, pos.Z, petMover.fixedY, tostring(petMover.isMoving),
                target and string.format("(%.1f,%.1f,%.1f)", target.X, target.Y, target.Z) or "NONE", rotation))
        else
            table.insert(debugInfo, "Pet " .. i .. " INVALID")
        end
    end
    table.insert(debugInfo, "=============================")
    
end

local function updateActivePetsLabel()
    if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("ActiveLabel") then
        gui.MainFrame.ActiveLabel.Text = "🎯 Active Pets: " .. #activePets
        
    end
end

local function createGUI()
    if PlayerGui:FindFirstChild("PetVisualPlacerGUI") then 
        PlayerGui.PetVisualPlacerGUI:Destroy() 
    end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "PetVisualPlacerGUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 200)
    mainFrame.Position = UDim2.new(0, -1000, 0, -1000)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- Enhanced shadow effect
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Name = "Shadow"
    shadowFrame.Size = UDim2.new(1, 10, 1, 10)
    shadowFrame.Position = UDim2.new(0, -5, 0, -5)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = 0.7
    shadowFrame.ZIndex = mainFrame.ZIndex - 1
    shadowFrame.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadowFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(70, 130, 255)
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainFrame
    
    -- Title bar with gradient
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 12)
    titleBarCorner.Parent = titleBar
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 130, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 200))
    }
    titleGradient.Rotation = 90
    titleGradient.Parent = titleBar
    
    -- Mask for rounded corners on title bar
    local titleMask = Instance.new("Frame")
    titleMask.Size = UDim2.new(1, 0, 0, 8)
    titleMask.Position = UDim2.new(0, 0, 1, -8)
    titleMask.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    titleMask.BorderSizePixel = 0
    titleMask.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -45, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, -2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🐾 Pet Placer"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 28
    titleLabel.TextScaled = false
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 26, 0, 26)
    minimizeButton.Position = UDim2.new(1, -35, 0, 5)
    
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = titleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 15)
    minimizeCorner.Parent = minimizeButton
    
    -- Content frame that will be hidden/shown
    local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true -- Tambahkan ini
contentFrame.Parent = mainFrame
    
    -- Status section
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, -20, 0, 60)
    statusFrame.Position = UDim2.new(0, 10, 0, 10)
    statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = contentFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusFrame
    
    local statusStroke = Instance.new("UIStroke")
    statusStroke.Color = Color3.fromRGB(45, 45, 50)
    statusStroke.Thickness = 1
    statusStroke.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = petVisualPlacerEnabled and "🟢 Status: Enabled" or "🔴 Status: Disabled"
    statusLabel.TextColor3 = petVisualPlacerEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusFrame
    
    local activeLabel = Instance.new("TextLabel")
    activeLabel.Name = "ActiveLabel"
    activeLabel.Size = UDim2.new(1, -20, 0, 25)
    activeLabel.Position = UDim2.new(0, 10, 0, 30)
    activeLabel.BackgroundTransparency = 1
    activeLabel.Text = "🎯 Active Pets: N/A"
    activeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    activeLabel.TextScaled = true
    activeLabel.Font = Enum.Font.Gotham
    activeLabel.TextXAlignment = Enum.TextXAlignment.Left
    activeLabel.Parent = statusFrame
    
    -- Button section
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, -20, 0, 45)
    buttonFrame.Position = UDim2.new(0, 10, 0, 75)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = contentFrame
    
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 160, 0, 43)
    toggleButton.Position = UDim2.new(0, 0, 0, 5)
    toggleButton.BackgroundColor3 = petVisualPlacerEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    toggleButton.Text = petVisualPlacerEnabled and "🛑 Disable" or "🚀 Enable"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = buttonFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = toggleButton
    
      -- Info frame
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, -170, 0, 45)
    infoFrame.Position = UDim2.new(0, 170, 0, 6)
    infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = buttonFrame

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoFrame

    local infoStroke = Instance.new("UIStroke")
    infoStroke.Color = Color3.fromRGB(45, 45, 50)
    infoStroke.Thickness = 1
    infoStroke.Parent = infoFrame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -10, 1, 0)
    infoLabel.Position = UDim2.new(0, 5, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "⚡ Enhanced Version Ready!"
    infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Parent = infoFrame
    
    -- Footer
    local featureLabel = Instance.new("TextLabel")
    featureLabel.Name = "FeatureLabel"
    featureLabel.Size = UDim2.new(1, -20, 0, 15)
    featureLabel.Position = UDim2.new(0, 10, 0, 135)
    featureLabel.BackgroundTransparency = 1
    featureLabel.Text = "💫 Made by Zysume Hub || Version 1.0"
    featureLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    featureLabel.TextScaled = true
    featureLabel.Font = Enum.Font.Gotham
    featureLabel.TextXAlignment = Enum.TextXAlignment.Left
    featureLabel.Parent = contentFrame
    
    -- Minimize functionality
    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if isMinimized then
            -- Minimize - hide content and shrink frame
            TweenService:Create(contentFrame, tweenInfo, {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            TweenService:Create(mainFrame, tweenInfo, {
                Size = UDim2.new(0, 350, 0, 40)
            }):Play()
            TweenService:Create(shadowFrame, tweenInfo, {
                Size = UDim2.new(1, 10, 0, 50)
            }):Play()
            titleMask.Visible = false
        else
            -- Restore - show content and expand frame
            TweenService:Create(mainFrame, tweenInfo, {
                Size = UDim2.new(0, 350, 0, 200)
            }):Play()
            TweenService:Create(shadowFrame, tweenInfo, {
                Size = UDim2.new(1, 10, 1, 10)
            }):Play()
            task.wait(0.15)
            TweenService:Create(contentFrame, tweenInfo, {
                Size = UDim2.new(1, 0, 1, -40)
            }):Play()
            titleMask.Visible = true
        end
    end)
    
    local activePetsUpdateConnection = task.spawn(function()
        while gui and gui.Parent and gui:FindFirstChild("MainFrame") do
            updateActivePetsLabel()
            task.wait(0.5)
        end
    end)
    
    local mouseConnection
    if petVisualPlacerEnabled then
        local mouse = LocalPlayer:GetMouse()
        mouseConnection = mouse.Button1Down:Connect(function()
            if petVisualPlacerEnabled then 
                handlePetPlacement(mouse.Hit.Position) 
            end
        end)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not petVisualPlacerEnabled or input.UserInputType ~= Enum.UserInputType.Touch then return end
            touchStartTime = tick()
            touchStartPosition = input.Position
        end)
        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed or not petVisualPlacerEnabled or input.UserInputType ~= Enum.UserInputType.Touch then return end
            local duration = tick() - touchStartTime
            local distanceMoved = (input.Position - touchStartPosition).Magnitude
            if duration >= holdDuration and distanceMoved < 5 then
                local camera = Workspace.CurrentCamera
                local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
                local raycastResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
                if raycastResult then 
                    handlePetPlacement(raycastResult.Position) 
                end
            end
        end)
    end

    toggleButton.MouseButton1Click:Connect(function()
        petVisualPlacerEnabled = not petVisualPlacerEnabled
        if petVisualPlacerEnabled then
            toggleButton.Text = "🛑 Disable"
            toggleButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            statusLabel.Text = "🟢 Status: Enabled"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            notify("Pet Placer", "Enabled!", 4)
            local mouse = LocalPlayer:GetMouse()
            mouseConnection = mouse.Button1Down:Connect(function()
                if petVisualPlacerEnabled then 
                    handlePetPlacement(mouse.Hit.Position) 
                end
            end)
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed or not petVisualPlacerEnabled or input.UserInputType ~= Enum.UserInputType.Touch then return end
                touchStartTime = tick()
                touchStartPosition = input.Position
            end)
            UserInputService.InputEnded:Connect(function(input, gameProcessed)
                if gameProcessed or not petVisualPlacerEnabled or input.UserInputType ~= Enum.UserInputType.Touch then return end
                local duration = tick() - touchStartTime
                local distanceMoved = (input.Position - touchStartPosition).Magnitude
                if duration >= holdDuration and distanceMoved < 5 then
                    local camera = Workspace.CurrentCamera
                    local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
                    local raycastResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
                    if raycastResult then 
                        handlePetPlacement(raycastResult.Position) 
                    end
                end
            end)
        else
            toggleButton.Text = "🚀 Enable"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            statusLabel.Text = "🔴 Status: Disabled"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            notify("Pet Placer", "Disabled", 2)
            if mouseConnection then
                mouseConnection:Disconnect()
                mouseConnection = nil
            end
        end
    end)
    
    -- Enhanced drag functionality with boundaries
    local dragToggle, dragSpeed, dragStart, startPos = nil, 0.25, nil, nil
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    local function updateInput(input)
        if not dragToggle then return end
        
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        
        -- Calculate boundaries with padding
        local padding = 10
        local frameWidth = mainFrame.Size.X.Offset
        local frameHeight = mainFrame.Size.Y.Offset
        
        -- Clamp position within screen bounds
        newX = math.max(padding, math.min(newX, screenSize.X - frameWidth - padding))
        newY = math.max(padding, math.min(newY, screenSize.Y - frameHeight - padding))
        
        local position = UDim2.new(0, newX, 0, newY)
        TweenService:Create(mainFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
    end
    
    -- Only allow dragging from title bar
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
            updateInput(input)
        end
    end)
    
    -- Screen size change handler
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        screenSize = workspace.CurrentCamera.ViewportSize
        local currentPos = mainFrame.Position
        local currentSize = isMinimized and 40 or 200
        
        -- Ensure GUI stays within new screen bounds
        local newX = math.max(10, math.min(currentPos.X.Offset, screenSize.X - mainFrame.Size.X.Offset - 10))
        local newY = math.max(10, math.min(currentPos.Y.Offset, screenSize.Y - currentSize - 10))
        
        if newX ~= currentPos.X.Offset or newY ~= currentPos.Y.Offset then
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0, newX, 0, newY)
            }):Play()
        end
    end)
    
    notify("Pet Placer", "GUI Just Loaded!", 3)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F8 then debugPetSystem() end
end)

local function getState() return petVisualPlacerEnabled end

local function setState(state)
    if gui and toggleButton then
        petVisualPlacerEnabled = state
        toggleButton.Text = state and "Disable" or "Enable"
        toggleButton.BackgroundColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        gui.MainFrame.ContentFrame.StatusFrame.StatusLabel.Text = "Status: " .. (state and "Enabled" or "Disabled")
        gui.MainFrame.ContentFrame.StatusFrame.StatusLabel.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end

createGUI()

_G.PetVisualPlacerGUI = {
    getPetVisualPlacerState = getState,
    setPetVisualPlacerState = setState,
    createGUI = createGUI,
    getActivePetsCount = function() return #activePets end
}
