-- Pet Level Up UI (Wood Style) - Case/Space/Dash Insensitive Flexible Pet Name Check
-- All variables/functions are uniquely prefixed to avoid conflict when embedded in other scripts

local PLU_Players = game:GetService("Players")
local PLU_TweenService = game:GetService("TweenService")
local PLU_Lighting = game:GetService("Lighting")
local PLU_camera = workspace.CurrentCamera
local PLU_localPlayer = PLU_Players.LocalPlayer

local PLU_originalFOV = PLU_camera and PLU_camera.FieldOfView or 70
local PLU_isZoomed = false
local PLU_zoomFOV = 60
local PLU_tweenTime = 0.4
local PLU_currentTween

local PLU_BROWN_BG = Color3.fromRGB(118, 61, 25)
local PLU_BROWN_LIGHT = Color3.fromRGB(164, 97, 43)
local PLU_BROWN_BORDER = Color3.fromRGB(51, 25, 0)
local PLU_ACCENT_GREEN = Color3.fromRGB(110, 196, 99)
local PLU_BUTTON_RED = Color3.fromRGB(255, 62, 62)
local PLU_BUTTON_GRAY = Color3.fromRGB(190, 190, 190)
local PLU_BUTTON_GREEN = Color3.fromRGB(85, 200, 85)
local PLU_BUTTON_GREEN_HOVER = Color3.fromRGB(120, 230, 120)
local PLU_FONT = Enum.Font.FredokaOne
local PLU_TILE_IMAGE = "rbxassetid://15910695828"

local PLU_validPets = {
    "raccoon",
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
local function PLU_toolIsValidPet(tool)
    local name = string.lower(tool.Name or "")
    for _, pat in ipairs(PLU_validPets) do
        local ok, found = pcall(function()
            return string.match(name, pat)
        end)
        if ok and found then return true end
    end
    return false
end

local PLU_gui = Instance.new("ScreenGui")
PLU_gui.Name = "PetLevelWoodUI_"..tostring(math.random(100000,999999))
PLU_gui.IgnoreGuiInset = true
PLU_gui.Parent = game.CoreGui

PLU_gui.AncestryChanged:Connect(function()
    if not PLU_gui:IsDescendantOf(game) then
        local blur = PLU_Lighting:FindFirstChild("ModalBlur")
        if blur then blur:Destroy() end
        if PLU_camera and PLU_isZoomed then
            if PLU_currentTween then PLU_currentTween:Cancel() end
            PLU_currentTween = PLU_TweenService:Create(PLU_camera, TweenInfo.new(PLU_tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                FieldOfView = PLU_originalFOV
            })
            PLU_currentTween:Play()
            PLU_isZoomed = false
        end
    end
end)

local PLU_mainFrame = Instance.new("Frame", PLU_gui)
PLU_mainFrame.Size = UDim2.new(0, 260, 0, 140)
PLU_mainFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
PLU_mainFrame.BackgroundColor3 = PLU_BROWN_BG
PLU_mainFrame.Active = true
PLU_mainFrame.Draggable = true
local PLU_frameCorner = Instance.new("UICorner", PLU_mainFrame)
PLU_frameCorner.CornerRadius = UDim.new(0, 10)
local PLU_frameStroke = Instance.new("UIStroke", PLU_mainFrame)
PLU_frameStroke.Thickness = 2
PLU_frameStroke.Color = PLU_BROWN_BORDER

local PLU_brownTexture = Instance.new("ImageLabel", PLU_mainFrame)
PLU_brownTexture.Size = UDim2.new(1, 0, 1, 0)
PLU_brownTexture.Position = UDim2.new(0, 0, 0, 0)
PLU_brownTexture.BackgroundTransparency = 1
PLU_brownTexture.Image = PLU_TILE_IMAGE
PLU_brownTexture.ImageTransparency = 0
PLU_brownTexture.ScaleType = Enum.ScaleType.Tile
PLU_brownTexture.TileSize = UDim2.new(0, 96, 0, 96)
PLU_brownTexture.ZIndex = 1

local PLU_topBar = Instance.new("Frame", PLU_mainFrame)
PLU_topBar.Size = UDim2.new(1, 0, 0, 32)
PLU_topBar.BackgroundColor3 = PLU_ACCENT_GREEN
PLU_topBar.BorderSizePixel = 0
local PLU_topBarCorner = Instance.new("UICorner", PLU_topBar)
PLU_topBarCorner.CornerRadius = UDim.new(0, 10)

local PLU_greenTexture = Instance.new("ImageLabel", PLU_topBar)
PLU_greenTexture.Size = UDim2.new(1, 0, 1, 0)
PLU_greenTexture.Position = UDim2.new(0, 0, 0, 0)
PLU_greenTexture.BackgroundTransparency = 1
PLU_greenTexture.Image = PLU_TILE_IMAGE
PLU_greenTexture.ImageTransparency = 0
PLU_greenTexture.ScaleType = Enum.ScaleType.Tile
PLU_greenTexture.TileSize = UDim2.new(0, 96, 0, 96)
PLU_greenTexture.ZIndex = 2

local PLU_topLabel = Instance.new("TextLabel", PLU_topBar)
PLU_topLabel.Size = UDim2.new(1, -64, 1, 0)
PLU_topLabel.Position = UDim2.new(0, 12, 0, 0)
PLU_topLabel.BackgroundTransparency = 1
PLU_topLabel.Text = "🌱 Level Up Your Pets"
PLU_topLabel.Font = PLU_FONT
PLU_topLabel.TextColor3 = Color3.new(1, 1, 1)
PLU_topLabel.TextStrokeTransparency = 0
PLU_topLabel.TextScaled = true
PLU_topLabel.TextXAlignment = Enum.TextXAlignment.Left
PLU_topLabel.ZIndex = 10

local PLU_infoBtn = Instance.new("TextButton", PLU_topBar)
PLU_infoBtn.Size = UDim2.new(0, 18, 0, 18)
PLU_infoBtn.Position = UDim2.new(1, -50, 0.5, -9)
PLU_infoBtn.BackgroundColor3 = PLU_BUTTON_GRAY
PLU_infoBtn.Text = "?"
PLU_infoBtn.Font = PLU_FONT
PLU_infoBtn.TextColor3 = Color3.fromRGB(65, 65, 65)
PLU_infoBtn.TextScaled = true
PLU_infoBtn.TextStrokeTransparency = 0.1
PLU_infoBtn.ZIndex = 11
local PLU_infoStroke = Instance.new("UIStroke", PLU_infoBtn)
PLU_infoStroke.Color = Color3.fromRGB(120,120,120)
PLU_infoStroke.Thickness = 1
PLU_infoBtn.MouseEnter:Connect(function() PLU_infoBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220) end)
PLU_infoBtn.MouseLeave:Connect(function() PLU_infoBtn.BackgroundColor3 = PLU_BUTTON_GRAY end)

local PLU_closeBtn = Instance.new("TextButton", PLU_topBar)
PLU_closeBtn.Size = UDim2.new(0, 18, 0, 18)
PLU_closeBtn.Position = UDim2.new(1, -25, 0.5, -9)
PLU_closeBtn.BackgroundColor3 = PLU_BUTTON_RED
PLU_closeBtn.Text = "X"
PLU_closeBtn.Font = PLU_FONT
PLU_closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
PLU_closeBtn.TextScaled = true
PLU_closeBtn.TextStrokeTransparency = 0.3
PLU_closeBtn.ZIndex = 11
local PLU_closeStroke = Instance.new("UIStroke", PLU_closeBtn)
PLU_closeStroke.Color = Color3.fromRGB(107, 0, 0)
PLU_closeStroke.Thickness = 1
PLU_closeBtn.MouseEnter:Connect(function() PLU_closeBtn.BackgroundColor3 = PLU_BROWN_LIGHT end)
PLU_closeBtn.MouseLeave:Connect(function() PLU_closeBtn.BackgroundColor3 = PLU_BUTTON_RED end)
PLU_closeBtn.MouseButton1Click:Connect(function() PLU_gui:Destroy() end)

local PLU_contentFrame = Instance.new("Frame", PLU_mainFrame)
PLU_contentFrame.Name = "ContentFrame"
PLU_contentFrame.Size = UDim2.new(1, -8, 1, -38)
PLU_contentFrame.Position = UDim2.new(0, 4, 0, 36)
PLU_contentFrame.BackgroundTransparency = 1
PLU_contentFrame.ZIndex = 2

local PLU_notificationLabel = Instance.new("TextLabel", PLU_contentFrame)
PLU_notificationLabel.Name = "NotificationLabel"
PLU_notificationLabel.Size = UDim2.new(0.92, 0, 0, 20)
PLU_notificationLabel.Position = UDim2.new(0.04, 0, 0, 0)
PLU_notificationLabel.BackgroundTransparency = 1
PLU_notificationLabel.Font = PLU_FONT
PLU_notificationLabel.Text = ""
PLU_notificationLabel.TextColor3 = Color3.fromRGB(255,100,100)
PLU_notificationLabel.TextStrokeTransparency = 0.3
PLU_notificationLabel.TextScaled = true
PLU_notificationLabel.TextXAlignment = Enum.TextXAlignment.Center
PLU_notificationLabel.ZIndex = 5

local function PLU_showAgeNotification(age)
    local notif = Instance.new("TextLabel", PLU_mainFrame)
    notif.Size = UDim2.new(0, 120, 0, 36)
    notif.Position = UDim2.new(0.5, -60, 0, 60)
    notif.BackgroundTransparency = 0.12
    notif.BackgroundColor3 = PLU_ACCENT_GREEN
    notif.Text = "+1 Age! ("..tostring(age)..")"
    notif.Font = PLU_FONT
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
        local t = PLU_TweenService:Create(notif, TweenInfo.new(0.6), {TextTransparency=1, BackgroundTransparency=1, TextStrokeTransparency=1})
        t:Play()
        t.Completed:Wait()
        notif:Destroy()
    end)
end

local function PLU_makeStyledButton(parent, text, yPos, color, hover)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = PLU_FONT
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.TextStrokeTransparency = 0.25
    btn.ZIndex = 2
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 7)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = PLU_BROWN_BORDER
    btnStroke.Thickness = 1
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = color end)
    return btn
end

local PLU_levelUpBtn = PLU_makeStyledButton(PLU_contentFrame, "Level Up 50 Instantly", 26, PLU_BUTTON_GREEN, PLU_BUTTON_GREEN_HOVER)

local PLU_credit = Instance.new("TextLabel", PLU_contentFrame)
PLU_credit.Name = "Credit"
PLU_credit.Size = UDim2.new(1, -10, 0, 16)
PLU_credit.Position = UDim2.new(0, 5, 1, -18)
PLU_credit.BackgroundTransparency = 1
PLU_credit.Text = "Remade by @Zeo"
PLU_credit.TextScaled = true
PLU_credit.Font = PLU_FONT
PLU_credit.TextColor3 = Color3.fromRGB(255, 255, 255)
PLU_credit.TextTransparency = 0.3
PLU_credit.TextStrokeTransparency = 0.8

local function PLU_miniLoading(customText, callback)
    local miniGui = Instance.new("ScreenGui", PLU_gui)
    miniGui.Name = "MiniLoading_"..tostring(math.random(100000,999999))
    miniGui.IgnoreGuiInset = true

    local miniFrame = Instance.new("Frame", miniGui)
    miniFrame.Size = UDim2.new(0, 240, 0, 80)
    miniFrame.Position = UDim2.new(0.5, -120, 0.5, -40)
    miniFrame.BackgroundColor3 = PLU_BROWN_BG
    miniFrame.BackgroundTransparency = 0
    miniFrame.BorderSizePixel = 0
    miniFrame.Visible = true

    local miniCorner = Instance.new("UICorner", miniFrame)
    miniCorner.CornerRadius = UDim.new(0, 10)
    local frameStroke = Instance.new("UIStroke", miniFrame)
    frameStroke.Thickness = 2
    frameStroke.Color = PLU_BROWN_BORDER

    local brownTexture = Instance.new("ImageLabel", miniFrame)
    brownTexture.Size = UDim2.new(1, 0, 1, 0)
    brownTexture.Position = UDim2.new(0, 0, 0, 0)
    brownTexture.BackgroundTransparency = 1
    brownTexture.Image = PLU_TILE_IMAGE
    brownTexture.ImageTransparency = 0
    brownTexture.ScaleType = Enum.ScaleType.Tile
    brownTexture.TileSize = UDim2.new(0, 96, 0, 96)
    brownTexture.ZIndex = 1

    local topBar = Instance.new("Frame", miniFrame)
    topBar.Size = UDim2.new(1, 0, 0, 22)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = PLU_ACCENT_GREEN
    topBar.ZIndex = 5
    local topBarCorner = Instance.new("UICorner", topBar)
    topBarCorner.CornerRadius = UDim.new(0, 10)

    local greenTexture = Instance.new("ImageLabel", topBar)
    greenTexture.Size = UDim2.new(1, 0, 1, 0)
    greenTexture.Position = UDim2.new(0, 0, 0, 0)
    greenTexture.BackgroundTransparency = 1
    greenTexture.Image = PLU_TILE_IMAGE
    greenTexture.ImageTransparency = 0
    greenTexture.ScaleType = Enum.ScaleType.Tile
    greenTexture.TileSize = UDim2.new(0, 96, 0, 96)
    greenTexture.ZIndex = 6

    local topLabel = Instance.new("TextLabel", topBar)
    topLabel.Size = UDim2.new(1, -12, 1, 0)
    topLabel.Position = UDim2.new(0, 6, 0, 0)
    topLabel.BackgroundTransparency = 1
    topLabel.Text = "Pet Leveling"
    topLabel.Font = PLU_FONT
    topLabel.TextColor3 = Color3.new(1, 1, 1)
    topLabel.TextStrokeTransparency = 0
    topLabel.TextScaled = true
    topLabel.TextXAlignment = Enum.TextXAlignment.Left
    topLabel.ZIndex = 7

    local progress = Instance.new("TextLabel", miniFrame)
    progress.Size = UDim2.new(1, -24, 0, 28)
    progress.Position = UDim2.new(0, 12, 0, 26)
    progress.BackgroundTransparency = 1
    progress.Font = PLU_FONT
    progress.TextColor3 = Color3.fromRGB(255, 255, 255)
    progress.TextStrokeTransparency = 0.2
    progress.Text = customText or "Pets Level Up! 0%"
    progress.TextScaled = true
    progress.TextTransparency = 0
    progress.ZIndex = 2

    local barBG = Instance.new("Frame", miniFrame)
    barBG.Size = UDim2.new(0.8, 0, 0, 16)
    barBG.Position = UDim2.new(0.1, 0, 1, -24)
    barBG.BackgroundColor3 = PLU_BROWN_LIGHT
    barBG.BorderSizePixel = 0
    barBG.ZIndex = 3
    local barBGCorner = Instance.new("UICorner", barBG)
    barBGCorner.CornerRadius = UDim.new(0, 6)
    local barBGStroke = Instance.new("UIStroke", barBG)
    barBGStroke.Color = PLU_BROWN_BORDER
    barBGStroke.Thickness = 1

    local barFill = Instance.new("Frame", barBG)
    barFill.BackgroundColor3 = PLU_ACCENT_GREEN
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

local function PLU_showInfoModal()
    if PLU_gui:FindFirstChild("InfoModal") then return end
    local blur = Instance.new("BlurEffect", PLU_Lighting)
    blur.Size = 16
    blur.Name = "ModalBlur"

    if PLU_camera and not PLU_isZoomed then
        if PLU_currentTween then PLU_currentTween:Cancel() end
        PLU_currentTween = PLU_TweenService:Create(PLU_camera, TweenInfo.new(PLU_tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            FieldOfView = PLU_zoomFOV
        })
        PLU_currentTween:Play()
        PLU_isZoomed = true
    end

    local modal = Instance.new("Frame", PLU_gui)
    modal.Name = "InfoModal"
    modal.Size = UDim2.new(0, 220, 0, 110)
    modal.Position = UDim2.new(0.5, -110, 0.5, -55)
    modal.BackgroundColor3 = PLU_BROWN_LIGHT
    modal.Active = true
    modal.ZIndex = 30
    local modalCorner = Instance.new("UICorner", modal)
    modalCorner.CornerRadius = UDim.new(0, 8)
    local modalStroke = Instance.new("UIStroke", modal)
    modalStroke.Color = PLU_BROWN_BORDER
    modalStroke.Thickness = 2

    local modalTexture = Instance.new("ImageLabel", modal)
    modalTexture.Name = "ModalBrownTexture"
    modalTexture.Size = UDim2.new(1, 0, 1, 0)
    modalTexture.Position = UDim2.new(0, 0, 0, 0)
    modalTexture.BackgroundTransparency = 1
    modalTexture.Image = PLU_TILE_IMAGE
    modalTexture.ImageTransparency = 0
    modalTexture.ScaleType = Enum.ScaleType.Tile
    modalTexture.TileSize = UDim2.new(0, 96, 0, 96)
    modalTexture.ZIndex = 30

    local textTile = Instance.new("Frame", modal)
    textTile.Size = UDim2.new(1, 0, 0, 18)
    textTile.Position = UDim2.new(0, 0, 0, 0)
    textTile.BackgroundColor3 = PLU_ACCENT_GREEN
    textTile.ZIndex = 32
    local textTileCorner = Instance.new("UICorner", textTile)
    textTileCorner.CornerRadius = UDim.new(0, 8)

    local textTileLabel = Instance.new("TextLabel", textTile)
    textTileLabel.Size = UDim2.new(1, -20, 1, 0)
    textTileLabel.Position = UDim2.new(0, 8, 0, 0)
    textTileLabel.BackgroundTransparency = 1
    textTileLabel.Text = "Disclaimer!"
    textTileLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textTileLabel.Font = PLU_FONT
    textTileLabel.TextScaled = true
    textTileLabel.ZIndex = 33
    textTileLabel.TextStrokeTransparency = 0

    local closeBtn2 = Instance.new("TextButton", textTile)
    closeBtn2.Size = UDim2.new(0, 16, 0, 16)
    closeBtn2.Position = UDim2.new(1, -18, 0, 1)
    closeBtn2.BackgroundColor3 = PLU_BUTTON_RED
    closeBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn2.Text = "✖"
    closeBtn2.TextScaled = true
    closeBtn2.Font = PLU_FONT
    closeBtn2.ZIndex = 34
    local closeStroke2 = Instance.new("UIStroke", closeBtn2)
    closeStroke2.Color = Color3.fromRGB(107, 0, 0)
    closeStroke2.Thickness = 2
    closeBtn2.MouseEnter:Connect(function() closeBtn2.BackgroundColor3 = Color3.fromRGB(200, 62, 62) end)
    closeBtn2.MouseLeave:Connect(function() closeBtn2.BackgroundColor3 = PLU_BUTTON_RED end)
    closeBtn2.MouseButton1Click:Connect(function()
        if blur then blur:Destroy() end
        if modal then modal:Destroy() end
        if PLU_camera and PLU_isZoomed then
            if PLU_currentTween then PLU_currentTween:Cancel() end
            PLU_currentTween = PLU_TweenService:Create(PLU_camera, TweenInfo.new(PLU_tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                FieldOfView = PLU_originalFOV
            })
            PLU_currentTween:Play()
            PLU_isZoomed = false
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
    infoLabel.Text = "Do not report this bug on discord.gg/growagarden!\nMade by @Zeo"
    infoLabel.TextWrapped = true
    infoLabel.Font = PLU_FONT
    infoLabel.TextScaled = true
    infoLabel.ZIndex = 31
    infoLabel.TextStrokeTransparency = 0.5
end

PLU_infoBtn.MouseButton1Click:Connect(PLU_showInfoModal)

PLU_levelUpBtn.MouseButton1Click:Connect(function()
    local char = PLU_localPlayer.Character or PLU_localPlayer.CharacterAdded:Wait()
    if not char then
        PLU_notificationLabel.Text = "Error: Character not loaded"
        wait(3)
        PLU_notificationLabel.Text = ""
        return
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local isValidPet = PLU_toolIsValidPet(tool)
        if isValidPet then
            PLU_notificationLabel.Text = ""
            PLU_mainFrame.Visible = false

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
                    PLU_mainFrame.Visible = true
                    PLU_notificationLabel.Text = "Pet leveled up to Age 50!"
                    wait(2)
                    PLU_notificationLabel.Text = ""
                    return
                end
                PLU_miniLoading("Leveling Up Age: " .. age, function()
                    tool.Name = basePetName .. " [" .. newWeight .. " KG] [Age " .. age .. "]"
                    PLU_showAgeNotification(age)
                    doNextAge(age + 1)
                end)
            end
            doNextAge(currentAge + 1)
        else
            PLU_notificationLabel.Text = "Please equip a valid pet"
            wait(3)
            PLU_notificationLabel.Text = ""
        end
    else
        PLU_notificationLabel.Text = "Please equip a valid pet"
        wait(3)
        PLU_notificationLabel.Text = ""
    end
end)
