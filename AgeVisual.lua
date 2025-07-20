local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local originalFOV = camera and camera.FieldOfView or 70
local isZoomed = false
local zoomFOV = 60
local tweenTime = 0.4
local currentTween

local BROWN_BG = Color3.fromRGB(118, 61, 25)
local BROWN_LIGHT = Color3.fromRGB(164, 97, 43)
local BROWN_BORDER = Color3.fromRGB(51, 25, 0)
local ACCENT_GREEN = Color3.fromRGB(110, 196, 99)
local BUTTON_RED = Color3.fromRGB(255, 62, 62)
local BUTTON_GRAY = Color3.fromRGB(190, 190, 190)
local BUTTON_GREEN = Color3.fromRGB(85, 200, 85)
local BUTTON_GREEN_HOVER = Color3.fromRGB(120, 230, 120)
local FONT = Enum.Font.FredokaOne
local TILE_IMAGE = "rbxassetid://15910695828"

local validPets = {
    "raccoon",
    "kitsune",
    "t[%s%-]*rex",
    "fennec[%s%-]*fox",
    "dragonfly",
    "butterfly",
    "disco[%s%-]*bee",
    "mimic[%s%-]*octopus",
    "spinosaurus",
    "queen[%s%-]*bee",
    "praying[%s%-]*mantis",
    "blood[%s%-]*owl"
}
local function toolIsValidPet(tool)
    local name = string.lower(tool.Name or "")
    for _, pat in ipairs(validPets) do
        local ok, found = pcall(function()
            return string.match(name, pat)
        end)
        if ok and found then return true end
    end
    return false
end

local gui = Instance.new("ScreenGui")
gui.Name = "PetLevelWoodUI"
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui -- safest, works on all executors

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

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 260, 0, 140)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
mainFrame.BackgroundColor3 = BROWN_BG
mainFrame.Active = true
mainFrame.Draggable = true
local frameCorner = Instance.new("UICorner", mainFrame)
frameCorner.CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Thickness = 2
frameStroke.Color = BROWN_BORDER

local brownTexture = Instance.new("ImageLabel", mainFrame)
brownTexture.Size = UDim2.new(1, 0, 1, 0)
brownTexture.Position = UDim2.new(0, 0, 0, 0)
brownTexture.BackgroundTransparency = 1
brownTexture.Image = TILE_IMAGE
brownTexture.ImageTransparency = 0
brownTexture.ScaleType = Enum.ScaleType.Tile
brownTexture.TileSize = UDim2.new(0, 96, 0, 96)
brownTexture.ZIndex = 1

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = ACCENT_GREEN
topBar.BorderSizePixel = 0
local topBarCorner = Instance.new("UICorner", topBar)
topBarCorner.CornerRadius = UDim.new(0, 10)

local greenTexture = Instance.new("ImageLabel", topBar)
greenTexture.Size = UDim2.new(1, 0, 1, 0)
greenTexture.Position = UDim2.new(0, 0, 0, 0)
greenTexture.BackgroundTransparency = 1
greenTexture.Image = TILE_IMAGE
greenTexture.ImageTransparency = 0
greenTexture.ScaleType = Enum.ScaleType.Tile
greenTexture.TileSize = UDim2.new(0, 96, 0, 96)
greenTexture.ZIndex = 2

local topLabel = Instance.new("TextLabel", topBar)
topLabel.Size = UDim2.new(1, -64, 1, 0)
topLabel.Position = UDim2.new(0, 12, 0, 0)
topLabel.BackgroundTransparency = 1
topLabel.Text = "🌱 Level Up Your Pets"
topLabel.Font = FONT
topLabel.TextColor3 = Color3.new(1, 1, 1)
topLabel.TextStrokeTransparency = 0
topLabel.TextScaled = true
topLabel.TextXAlignment = Enum.TextXAlignment.Left
topLabel.ZIndex = 10

local infoBtn = Instance.new("TextButton", topBar)
infoBtn.Size = UDim2.new(0, 18, 0, 18)
infoBtn.Position = UDim2.new(1, -50, 0.5, -9)
infoBtn.BackgroundColor3 = BUTTON_GRAY
infoBtn.Text = "?"
infoBtn.Font = FONT
infoBtn.TextColor3 = Color3.fromRGB(65, 65, 65)
infoBtn.TextScaled = true
infoBtn.TextStrokeTransparency = 0.1
infoBtn.ZIndex = 11
local infoStroke = Instance.new("UIStroke", infoBtn)
infoStroke.Color = Color3.fromRGB(120,120,120)
infoStroke.Thickness = 1
infoBtn.MouseEnter:Connect(function() infoBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220) end)
infoBtn.MouseLeave:Connect(function() infoBtn.BackgroundColor3 = BUTTON_GRAY end)

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -25, 0.5, -9)
closeBtn.BackgroundColor3 = BUTTON_RED
closeBtn.Text = "X"
closeBtn.Font = FONT
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.TextStrokeTransparency = 0.3
closeBtn.ZIndex = 11
local closeStroke = Instance.new("UIStroke", closeBtn)
closeStroke.Color = Color3.fromRGB(107, 0, 0)
closeStroke.Thickness = 1
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = BROWN_LIGHT end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = BUTTON_RED end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -8, 1, -38)
contentFrame.Position = UDim2.new(0, 4, 0, 36)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 2

local notificationLabel = Instance.new("TextLabel", contentFrame)
notificationLabel.Name = "NotificationLabel"
notificationLabel.Size = UDim2.new(0.92, 0, 0, 20)
notificationLabel.Position = UDim2.new(0.04, 0, 0, 0)
notificationLabel.BackgroundTransparency = 1
notificationLabel.Font = FONT
notificationLabel.Text = ""
notificationLabel.TextColor3 = Color3.fromRGB(255,100,100)
notificationLabel.TextStrokeTransparency = 0.3
notificationLabel.TextScaled = true
notificationLabel.TextXAlignment = Enum.TextXAlignment.Center
notificationLabel.ZIndex = 5

-- Age Notification Popup
local function showAgeNotification(age)
    local notif = Instance.new("TextLabel", mainFrame)
    notif.Size = UDim2.new(0, 120, 0, 36)
    notif.Position = UDim2.new(0.5, -60, 0, 60)
    notif.BackgroundTransparency = 0.12
    notif.BackgroundColor3 = ACCENT_GREEN
    notif.Text = "+1 Age! ("..tostring(age)..")"
    notif.Font = FONT
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.TextStrokeTransparency = 0.12
    notif.TextScaled = true
    notif.AnchorPoint = Vector2.new(0,0)
    local notifCorner = Instance.new("UICorner", notif)
    notifCorner.CornerRadius = UDim.new(0, 10)
    local notifStroke = Instance.new("UIStroke", notif)
    notifStroke.Color = Color3.fromRGB(70,140,60)
    notifStroke.Thickness = 1
    spawn(function()
        wait(1.1)
        local t = TweenService:Create(notif, TweenInfo.new(0.6), {TextTransparency=1, BackgroundTransparency=1, TextStrokeTransparency=1})
        t:Play()
        t.Completed:Wait()
        notif:Destroy()
    end)
end

-- Styled button
local function makeStyledButton(parent, text, yPos, color, hover)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = FONT
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.TextStrokeTransparency = 0.25
    btn.ZIndex = 2
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 7)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = BROWN_BORDER
    btnStroke.Thickness = 1
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = color end)
    return btn
end

local levelUpBtn = makeStyledButton(contentFrame, "Level Up 50 Instantly", 26, BUTTON_GREEN, BUTTON_GREEN_HOVER)

local credit = Instance.new("TextLabel", contentFrame)
credit.Name = "Credit"
credit.Size = UDim2.new(1, -10, 0, 16)
credit.Position = UDim2.new(0, 5, 1, -18)
credit.BackgroundTransparency = 1
credit.Text = "Remade by @Zeo"
credit.TextScaled = true
credit.Font = FONT
credit.TextColor3 = Color3.fromRGB(255, 255, 255)
credit.TextTransparency = 0.3
credit.TextStrokeTransparency = 0.8

-- Mini Loading Modal (Brown Style)
local function miniLoading(customText, callback)
    local miniGui = Instance.new("ScreenGui", gui)
    miniGui.Name = "MiniLoading"
    miniGui.IgnoreGuiInset = true

    local miniFrame = Instance.new("Frame", miniGui)
    miniFrame.Size = UDim2.new(0, 240, 0, 80)
    miniFrame.Position = UDim2.new(0.5, -120, 0.5, -40)
    miniFrame.BackgroundColor3 = BROWN_BG
    miniFrame.BackgroundTransparency = 0
    miniFrame.BorderSizePixel = 0
    miniFrame.Visible = true

    local miniCorner = Instance.new("UICorner", miniFrame)
    miniCorner.CornerRadius = UDim.new(0, 10)
    local frameStroke = Instance.new("UIStroke", miniFrame)
    frameStroke.Thickness = 2
    frameStroke.Color = BROWN_BORDER

    local brownTexture = Instance.new("ImageLabel", miniFrame)
    brownTexture.Size = UDim2.new(1, 0, 1, 0)
    brownTexture.Position = UDim2.new(0, 0, 0, 0)
    brownTexture.BackgroundTransparency = 1
    brownTexture.Image = TILE_IMAGE
    brownTexture.ImageTransparency = 0
    brownTexture.ScaleType = Enum.ScaleType.Tile
    brownTexture.TileSize = UDim2.new(0, 96, 0, 96)
    brownTexture.ZIndex = 1

    local topBar = Instance.new("Frame", miniFrame)
    topBar.Size = UDim2.new(1, 0, 0, 22)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = ACCENT_GREEN
    topBar.ZIndex = 5
    local topBarCorner = Instance.new("UICorner", topBar)
    topBarCorner.CornerRadius = UDim.new(0, 10)

    local greenTexture = Instance.new("ImageLabel", topBar)
    greenTexture.Size = UDim2.new(1, 0, 1, 0)
    greenTexture.Position = UDim2.new(0, 0, 0, 0)
    greenTexture.BackgroundTransparency = 1
    greenTexture.Image = TILE_IMAGE
    greenTexture.ImageTransparency = 0
    greenTexture.ScaleType = Enum.ScaleType.Tile
    greenTexture.TileSize = UDim2.new(0, 96, 0, 96)
    greenTexture.ZIndex = 6

    local topLabel = Instance.new("TextLabel", topBar)
    topLabel.Size = UDim2.new(1, -12, 1, 0)
    topLabel.Position = UDim2.new(0, 6, 0, 0)
    topLabel.BackgroundTransparency = 1
    topLabel.Text = "Pet Leveling"
    topLabel.Font = FONT
    topLabel.TextColor3 = Color3.new(1, 1, 1)
    topLabel.TextStrokeTransparency = 0
    topLabel.TextScaled = true
    topLabel.TextXAlignment = Enum.TextXAlignment.Left
    topLabel.ZIndex = 7

    local progress = Instance.new("TextLabel", miniFrame)
    progress.Size = UDim2.new(1, -24, 0, 28)
    progress.Position = UDim2.new(0, 12, 0, 26)
    progress.BackgroundTransparency = 1
    progress.Font = FONT
    progress.TextColor3 = Color3.fromRGB(255, 255, 255)
    progress.TextStrokeTransparency = 0.2
    progress.Text = customText or "Pets Level Up! 0%"
    progress.TextScaled = true
    progress.TextTransparency = 0
    progress.ZIndex = 2

    local barBG = Instance.new("Frame", miniFrame)
    barBG.Size = UDim2.new(0.8, 0, 0, 16)
    barBG.Position = UDim2.new(0.1, 0, 1, -24)
    barBG.BackgroundColor3 = BROWN_LIGHT
    barBG.BorderSizePixel = 0
    barBG.ZIndex = 3
    local barBGCorner = Instance.new("UICorner", barBG)
    barBGCorner.CornerRadius = UDim.new(0, 6)
    local barBGStroke = Instance.new("UIStroke", barBG)
    barBGStroke.Color = BROWN_BORDER
    barBGStroke.Thickness = 1

    local barFill = Instance.new("Frame", barBG)
    barFill.BackgroundColor3 = ACCENT_GREEN
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.ZIndex = 4
    local barFillCorner = Instance.new("UICorner", barFill)
    barFillCorner.CornerRadius = UDim.new(0, 6)

    spawn(function()
        for i = 1, 100 do
            progress.Text = (customText or "Pets Level Up!") .. " " .. i .. "%"
            barFill.Size = UDim2.new(i / 100, 0, 1, 0)
            wait(0.012)
        end
        wait(0.15)
        miniGui:Destroy()
        if callback then callback() end
    end)
end

local function showInfoModal()
    if gui:FindFirstChild("InfoModal") then return end
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 16
    blur.Name = "ModalBlur"

    if camera and not isZoomed then
        if currentTween then currentTween:Cancel() end
        currentTween = TweenService:Create(camera, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            FieldOfView = zoomFOV
        })
        currentTween:Play()
        isZoomed = true
    end

    local modal = Instance.new("Frame", gui)
    modal.Name = "InfoModal"
    modal.Size = UDim2.new(0, 220, 0, 110)
    modal.Position = UDim2.new(0.5, -110, 0.5, -55)
    modal.BackgroundColor3 = BROWN_LIGHT
    modal.Active = true
    modal.ZIndex = 30
    local modalCorner = Instance.new("UICorner", modal)
    modalCorner.CornerRadius = UDim.new(0, 8)
    local modalStroke = Instance.new("UIStroke", modal)
    modalStroke.Color = BROWN_BORDER
    modalStroke.Thickness = 2

    local modalTexture = Instance.new("ImageLabel", modal)
    modalTexture.Name = "ModalBrownTexture"
    modalTexture.Size = UDim2.new(1, 0, 1, 0)
    modalTexture.Position = UDim2.new(0, 0, 0, 0)
    modalTexture.BackgroundTransparency = 1
    modalTexture.Image = TILE_IMAGE
    modalTexture.ImageTransparency = 0
    modalTexture.ScaleType = Enum.ScaleType.Tile
    modalTexture.TileSize = UDim2.new(0, 96, 0, 96)
    modalTexture.ZIndex = 30

    local textTile = Instance.new("Frame", modal)
    textTile.Size = UDim2.new(1, 0, 0, 18)
    textTile.Position = UDim2.new(0, 0, 0, 0)
    textTile.BackgroundColor3 = ACCENT_GREEN
    textTile.ZIndex = 32
    local textTileCorner = Instance.new("UICorner", textTile)
    textTileCorner.CornerRadius = UDim.new(0, 8)

    local textTileLabel = Instance.new("TextLabel", textTile)
    textTileLabel.Size = UDim2.new(1, -20, 1, 0)
    textTileLabel.Position = UDim2.new(0, 8, 0, 0)
    textTileLabel.BackgroundTransparency = 1
    textTileLabel.Text = "Disclaimer!"
    textTileLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textTileLabel.Font = FONT
    textTileLabel.TextScaled = true
    textTileLabel.ZIndex = 33
    textTileLabel.TextStrokeTransparency = 0

    local closeBtn2 = Instance.new("TextButton", textTile)
    closeBtn2.Size = UDim2.new(0, 16, 0, 16)
    closeBtn2.Position = UDim2.new(1, -18, 0, 1)
    closeBtn2.BackgroundColor3 = BUTTON_RED
    closeBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn2.Text = "✖"
    closeBtn2.TextScaled = true
    closeBtn2.Font = FONT
    closeBtn2.ZIndex = 34
    local closeStroke2 = Instance.new("UIStroke", closeBtn2)
    closeStroke2.Color = Color3.fromRGB(107, 0, 0)
    closeStroke2.Thickness = 2
    closeBtn2.MouseEnter:Connect(function() closeBtn2.BackgroundColor3 = Color3.fromRGB(200, 62, 62) end)
    closeBtn2.MouseLeave:Connect(function() closeBtn2.BackgroundColor3 = BUTTON_RED end)
    closeBtn2.MouseButton1Click:Connect(function()
        if blur then blur:Destroy() end
        if modal then modal:Destroy() end
        if camera and isZoomed then
            if currentTween then currentTween:Cancel() end
            currentTween = TweenService:Create(camera, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                FieldOfView = originalFOV
            })
            currentTween:Play()
            isZoomed = false
        end
    end)

    local infoBox = Instance.new("Frame", modal)
    infoBox.Size = UDim2.new(1, -10, 1, -21)
    infoBox.Position = UDim2.new(0, 5, 0, 16)
    infoBox.BackgroundColor3 = Color3.fromRGB(196, 164, 132)
    infoBox.BackgroundTransparency = 0
    infoBox.ZIndex = 30
    local infoBoxCorner = Instance.new("UICorner", infoBox)
    infoBoxCorner.CornerRadius = UDim.new(0, 7)

    local infoBoxGradient = Instance.new("UIGradient", infoBox)
    infoBoxGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(164, 97, 43)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 43, 18))
    }

    local infoLabel = Instance.new("TextLabel", infoBox)
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.Position = UDim2.new(0, 0, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.Text = "This only works on divine pets\nDo not report this bug on discord.gg/growagarden!\nMade by @Zeo"
    infoLabel.TextWrapped = true
    infoLabel.Font = FONT
    infoLabel.TextScaled = true
    infoLabel.ZIndex = 31
    infoLabel.TextStrokeTransparency = 0.5
end

infoBtn.MouseButton1Click:Connect(showInfoModal)

levelUpBtn.MouseButton1Click:Connect(function()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    if not char then
        notificationLabel.Text = "Error: Character not loaded"
        wait(3)
        notificationLabel.Text = ""
        return
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local isValidPet = toolIsValidPet(tool)
        if isValidPet then
            notificationLabel.Text = ""
            mainFrame.Visible = false

            local currentWeight = 0
            local currentAge = 0
            local weightMatch = string.match(tool.Name, "%[(.-) KG%]")
            local ageMatch = string.match(tool.Name, "%[Age (.-)%]")
            if weightMatch then currentWeight = tonumber(weightMatch) or 0 end
            if ageMatch then currentAge = tonumber(ageMatch) or 0 end

            local newWeight = tonumber(string.format("%.2f", currentWeight + 5))
            local basePetName = string.match(tool.Name, "^(.-) %[") or tool.Name

            local function doNextAge(age)
                if age > 50 then
                    mainFrame.Visible = true
                    notificationLabel.Text = "Pet leveled up to Age 50!"
                    wait(2)
                    notificationLabel.Text = ""
                    return
                end
                miniLoading("Leveling Up Age: " .. age, function()
                    tool.Name = basePetName .. " [" .. newWeight .. " KG] [Age " .. age .. "]"
                    showAgeNotification(age)
                    doNextAge(age + 1)
                end)
            end
            doNextAge(currentAge + 1)
        else
            notificationLabel.Text = "Please equip a valid pet"
            wait(3)
            notificationLabel.Text = ""
        end
    else
        notificationLabel.Text = "Please equip a valid pet"
        wait(3)
        notificationLabel.Text = ""
    end
end)
