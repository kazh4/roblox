-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KAZHA"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.Text = "ESP AN"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 18
toggleButton.Parent = frame

local bothButton = Instance.new("TextButton")
bothButton.Size = UDim2.new(1, -20, 0, 40)
bothButton.Position = UDim2.new(0, 10, 0, 90)
bothButton.Text = "both = T"
bothButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
bothButton.TextColor3 = Color3.new(1,1,1)
bothButton.Font = Enum.Font.SourceSans
bothButton.TextSize = 18
bothButton.Parent = frame

-- ESP Variablen
local espEnabled = false
local highlights = {}
local characterConnections = {}

-- Aimlock Variablen
local aimlockEnabled = false
local holdingRightClick = false

-- ESP Funktionen
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and LocalPlayer.Character and LocalPlayer:DistanceFromCharacter(char:GetPivot().Position) <= 300 then
                if espEnabled then
                    if not highlights[player] then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Adornee = char
                        hl.Parent = char
                        highlights[player] = hl
                    else
                        highlights[player].Adornee = char
                    end
                else
                    if highlights[player] then
                        highlights[player]:Destroy()
                        highlights[player] = nil
                    end
                end
            end
        end
    end
end

local function connectCharacterAdded(player)
    if player ~= LocalPlayer and not characterConnections[player] then
        characterConnections[player] = player.CharacterAdded:Connect(function(char)
            wait(1)
            if espEnabled and LocalPlayer:DistanceFromCharacter(char:GetPivot().Position) <= 300 then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Adornee = char
                hl.Parent = char
                highlights[player] = hl
            end
        end)
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    toggleButton.Text = espEnabled and "ESP AUS" or "ESP AN"
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            connectCharacterAdded(player)
            if player.Character and LocalPlayer:DistanceFromCharacter(player.Character:GetPivot().Position) <= 300 then
                local char = player.Character
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Adornee = char
                hl.Parent = char
                highlights[player] = hl
            end
        end
    else
        for _, hl in pairs(highlights) do
            hl:Destroy()
        end
        highlights = {}
    end
end

toggleButton.MouseButton1Click:Connect(toggleESP)

Players.PlayerAdded:Connect(function(player)
    connectCharacterAdded(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
    if characterConnections[player] then
        characterConnections[player]:Disconnect()
        characterConnections[player] = nil
    end
end)

-- ESP Loop
RunService.Heartbeat:Connect(function()
    if espEnabled then
        updateESP()
    end
end)

-- Aimlock Funktion
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = 40
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDistance then
                closestPlayer = player
                shortestDistance = dist
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimlockEnabled and holdingRightClick then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end
end)

-- Maus Taste halten
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRightClick = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRightClick = false
    end
end)

-- Taste T als Umschalter für ESP und Aimlock
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        espEnabled = not espEnabled
        aimlockEnabled = not aimlockEnabled
        toggleButton.Text = espEnabled and "ESP AUS" or "ESP AN"
    end
end)

bothButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    aimlockEnabled = not aimlockEnabled
    toggleButton.Text = espEnabled and "ESP AUS" or "ESP AN"
end)
