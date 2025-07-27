-- Pet Mutation Finder with Styled ESP + Credit Footer
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Camera setup
local camera = workspace.CurrentCamera
local originalFOV = camera and camera.FieldOfView or 70
local isZoomed = false
local zoomFOV = 60
local tweenTime = 0.4
local currentTween

local mutations = {
    "Shiny", "Inverted", "Frozen", "Windy", "Golden", "Mega", "Tiny",
    "Tranquil", "IronSkin", "Radiant", "Rainbow", "Shocked", "Ascended"
}
local currentMutation = mutations[math.random(#mutations)]
local espVisible = true
local rerollOnCooldown = false
local cooldownTimeLeft = 0

-- UI Colors
local BROWN_BG = Color3.fromRGB(118, 61, 25)
local BROWN_LIGHT = Color3.fromRGB(164, 97, 43)
local BROWN_BORDER = Color3.fromRGB(51, 25, 0)
local ACCENT_GREEN = Color3.fromRGB(110, 196, 99)
local BUTTON_YELLOW = Color3.fromRGB(255, 214, 61)
local BUTTON_RED = Color3.fromRGB(255, 62, 62)
local BUTTON_GRAY = Color3.fromRGB(190, 190, 190)
local BUTTON_BLUE = Color3.fromRGB(66, 150, 255)
local BUTTON_BLUE_HOVER = Color3.fromRGB(85, 180, 255)
local BUTTON_GREEN = Color3.fromRGB(85, 200, 85)
local BUTTON_GREEN_HOVER = Color3.fromRGB(120, 230, 120)
local BUTTON_RED_HOVER = Color3.fromRGB(255, 100, 100)
local FONT = Enum.Font.FredokaOne
local TILE_IMAGE = "rbxassetid://15910695828"

-- Create new styled GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PetMutationFinder"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

gui.AncestryChanged:Connect(function()
    if not gui:IsDescendantOf(game) then
        local blur = Lighting:FindFirstChild("ModalBlur")
        if blur then blur:Destroy() end
        if camera and isZoomed then
            if currentTween then currentTween:Cancel() end
            currentTween = TweenService:Create(camera, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                FieldOfView = originalFOV
            })
            currentTween:Play()
            isZoomed = false
        end
    end
end)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 120)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -60)
mainFrame.BackgroundColor3 = BROWN_BG
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true
local frameCorner = Instance.new("UICorner", mainFrame)
frameCorner.CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Thickness = 2
frameStroke.Color = BROWN_BORDER

local brownTexture = Instance.new("ImageLabel")
brownTexture.Name = "BrownTexture"
brownTexture.Size = UDim2.new(1, 0, 1, 0)
brownTexture.Position = UDim2.new(0, 0, 0, 0)
brownTexture.BackgroundTransparency = 1
brownTexture.Image = TILE_IMAGE
brownTexture.ImageTransparency = 0
brownTexture.ScaleType = Enum.ScaleType.Tile
brownTexture.TileSize = UDim2.new(0, 96, 0, 96)
brownTexture.ZIndex = 1
brownTexture.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 26)
topBar.BackgroundColor3 = ACCENT_GREEN
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
local topBarCorner = Instance.new("UICorner", topBar)
topBarCorner.CornerRadius = UDim.new(0, 10)

local greenTexture = Instance.new("ImageLabel")
greenTexture.Name = "GreenTexture"
greenTexture.Size = UDim2.new(1, 0, 1, 0)
greenTexture.Position = UDim2.new(0, 0, 0, 0)
greenTexture.BackgroundTransparency = 1
greenTexture.Image = TILE_IMAGE
greenTexture.ImageTransparency = 0
greenTexture.ScaleType = Enum.ScaleType.Tile
greenTexture.TileSize = UDim2.new(0, 96, 0, 96)
greenTexture.ZIndex = 1
greenTexture.Parent = topBar

local topLabel = Instance.new("TextLabel")
topLabel.Size = UDim2.new(1, -62, 1, 0)
topLabel.Position = UDim2.new(0, 8, 0, 0)
topLabel.BackgroundTransparency = 1
topLabel.Text = "🔬 Pet Mutation Finder"
topLabel.Font = FONT
topLabel.TextColor3 = Color3.new(1, 1, 1)
topLabel.TextStrokeTransparency = 0
topLabel.TextStrokeColor3 = Color3.fromRGB(45, 66, 0)
topLabel.TextScaled = true
topLabel.TextXAlignment = Enum.TextXAlignment.Left
topLabel.ZIndex = 1
topLabel.Parent = topBar

local infoBtn = Instance.new("TextButton")
infoBtn.Size = UDim2.new(0, 18, 0, 18)
infoBtn.Position = UDim2.new(1, -50, 0.5, -9)
infoBtn.BackgroundColor3 = BUTTON_GRAY
infoBtn.Text = "?"
infoBtn.Font = FONT
infoBtn.TextColor3 = Color3.fromRGB(65, 65, 65)
infoBtn.TextScaled = true
infoBtn.TextStrokeTransparency = 0.1
infoBtn.Parent = topBar
infoBtn.ZIndex = 2
local infoStroke = Instance.new("UIStroke", infoBtn)
infoStroke.Color = Color3.fromRGB(120,120,120)
infoStroke.Thickness = 1
infoBtn.MouseEnter:Connect(function()
    infoBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
end)
infoBtn.MouseLeave:Connect(function()
    infoBtn.BackgroundColor3 = BUTTON_GRAY
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -25, 0.5, -9)
closeBtn.BackgroundColor3 = BUTTON_RED
closeBtn.Text = "X"
closeBtn.Font = FONT
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.TextStrokeTransparency = 0.3
closeBtn.Parent = topBar
closeBtn.ZIndex = 2
local closeStroke = Instance.new("UIStroke", closeBtn)
closeStroke.Color = Color3.fromRGB(107, 0, 0)
closeStroke.Thickness = 1
closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = BUTTON_RED_HOVER
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = BUTTON_RED
end)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -8, 1, -38)
contentFrame.Position = UDim2.new(0, 4, 0, 32)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 2
contentFrame.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = FONT
statusLabel.Text = "ESP Active"
statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
statusLabel.TextScaled = true
statusLabel.Parent = contentFrame

local function makeStyledButton(parent, text, yPos, color, hover)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 26)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = FONT
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.TextStrokeTransparency = 0.25
    btn.ZIndex = 2
    btn.Parent = parent
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 7)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = BROWN_BORDER
    btnStroke.Thickness = 1
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = hover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = color
    end)
    return btn
end

local toggleBtn = makeStyledButton(contentFrame, "Toggle ESP (ON)", 28, BUTTON_GREEN, BUTTON_GREEN_HOVER)
local rerollBtn = makeStyledButton(contentFrame, "Mutation Reroll", 58, BUTTON_BLUE, BUTTON_BLUE_HOVER)

local function updateToggleBtn()
    toggleBtn.BackgroundColor3 = espVisible and BUTTON_GREEN or BUTTON_RED
    toggleBtn.Text = espVisible and "Toggle ESP (ON)" or "Toggle ESP (OFF)"
    statusLabel.Text = espVisible and "ESP Active" or "ESP Disabled"
end
updateToggleBtn()

-- 🔍 Find mutation machine
local function findMachine()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("mutation") then
            return obj
        end
    end
end

local machine = findMachine()
if not machine or not machine:FindFirstChildWhichIsA("BasePart") then
    warn("Pet Mutation Machine not found.")
    gui:Destroy()
    return
end

local basePart = machine:FindFirstChildWhichIsA("BasePart")

-- 💡 Stylish ESP
local espGui = Instance.new("BillboardGui", basePart)
espGui.Name = "MutationESP"
espGui.Adornee = basePart
espGui.Size = UDim2.new(0, 200, 0, 40)
espGui.StudsOffset = Vector3.new(0, 3, 0)
espGui.AlwaysOnTop = true
espGui.Enabled = espVisible

local espLabel = Instance.new("TextLabel", espGui)
espLabel.Size = UDim2.new(1, 0, 1, 0)
espLabel.BackgroundTransparency = 1
espLabel.Font = Enum.Font.GothamBold
espLabel.TextSize = 24
espLabel.TextStrokeTransparency = 0.3
espLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
espLabel.Text = currentMutation

-- 🌈 Animate rainbow color
local hue = 0
RunService.RenderStepped:Connect(function()
    if espVisible and espGui.Enabled then
        hue = (hue + 0.01) % 1
        espLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end
end)

-- ♻️ Reroll effect
local function animateMutationReroll()
    local duration = 2
    local interval = 0.1
    for i = 1, math.floor(duration / interval) do
        espLabel.Text = mutations[math.random(#mutations)]
        task.wait(interval)
    end
    
    currentMutation = mutations[math.random(#mutations)]
    espLabel.Text = currentMutation
end

-- Button functionality
toggleBtn.MouseButton1Click:Connect(function()
    espVisible = not espVisible
    espGui.Enabled = espVisible
    updateToggleBtn()
end)

-- Fixed cooldown functionality
rerollBtn.MouseButton1Click:Connect(function()
    if rerollOnCooldown then return end
    
    rerollOnCooldown = true
    rerollBtn.BackgroundColor3 = BUTTON_GRAY
    rerollBtn.Text = "Rerolling..."
    statusLabel.Text = "Rerolling mutation..."
    
    -- Run animation in a separate thread
    task.spawn(function()
        animateMutationReroll()
        
        statusLabel.Text = "Mutation rerolled!"
        rerollBtn.Text = "Cooldown (3.0s)"
        
        -- Start cooldown timer in a separate thread
        task.spawn(function()
            local cooldown = 3
            local startTime = tick()
            
            while tick() - startTime < cooldown do
                local elapsed = tick() - startTime
                local left = cooldown - elapsed
                rerollBtn.Text = string.format("Cooldown (%.1fs)", left)
                task.wait(0.05)
            end
            
            -- Reset button after cooldown
            rerollBtn.Text = "Mutation Reroll"
            rerollBtn.BackgroundColor3 = BUTTON_BLUE
            rerollOnCooldown = false
            statusLabel.Text = espVisible and "ESP Active" or "ESP Disabled"
        end)
    end)
end)

-- Modal functionality
infoBtn.MouseButton1Click:Connect(function()
    if gui:FindFirstChild("InfoModal") then
        return
    end

    -- Create blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 16
    blur.Name = "ModalBlur"
    blur.Parent = Lighting

    -- Apply camera zoom
    if camera and not isZoomed then
        if currentTween then currentTween:Cancel() end
        originalFOV = camera.FieldOfView
        currentTween = TweenService:Create(camera, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            FieldOfView = zoomFOV
        })
        currentTween:Play()
        isZoomed = true
    end

    local modal = Instance.new("Frame")
    modal.Name = "InfoModal"
    modal.Size = UDim2.new(0, 220, 0, 110)
    modal.Position = UDim2.new(0.5, -110, 0.5, -55)
    modal.BackgroundColor3 = BROWN_LIGHT
    modal.Active = true
    modal.ZIndex = 30
    modal.Parent = gui
    local modalCorner = Instance.new("UICorner", modal)
    modalCorner.CornerRadius = UDim.new(0, 8)
    local modalStroke = Instance.new("UIStroke", modal)
    modalStroke.Color = BROWN_BORDER
    modalStroke.Thickness = 2

    local modalTexture = Instance.new("ImageLabel")
    modalTexture.Name = "ModalBrownTexture"
    modalTexture.Size = UDim2.new(1, 0, 1, 0)
    modalTexture.Position = UDim2.new(0, 0, 0, 0)
    modalTexture.BackgroundTransparency = 1
    modalTexture.Image = TILE_IMAGE
    modalTexture.ImageTransparency = 0
    modalTexture.ScaleType = Enum.ScaleType.Tile
    modalTexture.TileSize = UDim2.new(0, 96, 0, 96)
    modalTexture.ZIndex = 30
    modalTexture.Parent = modal

    local textTile = Instance.new("Frame")
    textTile.Size = UDim2.new(1, 0, 0, 18)
    textTile.Position = UDim2.new(0, 0, 0, 0)
    textTile.BackgroundColor3 = ACCENT_GREEN
    textTile.ZIndex = 30
    textTile.Parent = modal
    local textTileCorner = Instance.new("UICorner", textTile)
    textTileCorner.CornerRadius = UDim.new(0, 8)

    local textTileLabel = Instance.new("TextLabel")
    textTileLabel.Size = UDim2.new(1, -20, 1, 0)
    textTileLabel.Position = UDim2.new(0, 8, 0, 0)
    textTileLabel.BackgroundTransparency = 1
    textTileLabel.Text = "Disclaimer!"
    textTileLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textTileLabel.Font = FONT
    textTileLabel.TextScaled = true
    textTileLabel.ZIndex = 31
    textTileLabel.TextStrokeTransparency = 0
    textTileLabel.Parent = textTile

    local closeBtn2 = Instance.new("TextButton")
    closeBtn2.Size = UDim2.new(0, 16, 0, 16)
    closeBtn2.Position = UDim2.new(1, -18, 0, 1)
    closeBtn2.BackgroundColor3 = BUTTON_RED
    closeBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn2.Text = "✖"
    closeBtn2.TextScaled = true
    closeBtn2.Font = FONT
    closeBtn2.ZIndex = 32
    closeBtn2.Parent = textTile
    local closeStroke2 = Instance.new("UIStroke", closeBtn2)
    closeStroke2.Color = Color3.fromRGB(107, 0, 0)
    closeStroke2.Thickness = 2
    closeBtn2.MouseEnter:Connect(function()
        closeBtn2.BackgroundColor3 = BUTTON_RED_HOVER
    end)
    closeBtn2.MouseLeave:Connect(function()
        closeBtn2.BackgroundColor3 = BUTTON_RED
    end)
    closeBtn2.MouseButton1Click:Connect(function()
        -- Remove blur effect
        if blur then blur:Destroy() end
        
        -- Reset camera zoom
        if camera and isZoomed then
            if currentTween then currentTween:Cancel() end
            currentTween = TweenService:Create(camera, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                FieldOfView = originalFOV
            })
            currentTween:Play()
            isZoomed = false
        end
        
        -- Remove modal
        if modal then modal:Destroy() end
    end)

    local infoBox = Instance.new("Frame")
    infoBox.Size = UDim2.new(1, -10, 1, -21)
    infoBox.Position = UDim2.new(0, 5, 0, 16)
    infoBox.BackgroundColor3 = Color3.fromRGB(196, 164, 132)
    infoBox.BackgroundTransparency = 0
    infoBox.ZIndex = 30
    infoBox.Parent = modal

    local infoBoxCorner = Instance.new("UICorner", infoBox)
    infoBoxCorner.CornerRadius = UDim.new(0, 7)

    local infoBoxGradient = Instance.new("UIGradient", infoBox)
    infoBoxGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(164, 97, 43)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 43, 18))
    }

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.Position = UDim2.new(0, 0, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.Text = "This works only with divine pets!\nDo not report this bug on discord.gg/growagarden!"
    infoLabel.TextWrapped = true
    infoLabel.Font = FONT
    infoLabel.TextScaled = true
    infoLabel.ZIndex = 31
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.Parent = infoBox
end)
