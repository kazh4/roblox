-- Dienste holen
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

local aimButton = Instance.new("TextButton")
aimButton.Size = UDim2.new(1, -20, 0, 40)
aimButton.Position = UDim2.new(0, 10, 0, 90)
aimButton.Text = "Aimlock AN"
aimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
aimButton.TextColor3 = Color3.new(1,1,1)
aimButton.Font = Enum.Font.SourceSans
aimButton.TextSize = 18
aimButton.Parent = frame

local espEnabled = false
local aimEnabled = false
local highlights = {}
local characterConnections = {}

-- ESP Funktionen
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude) or math.huge
            if distance <= 300 then
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
            if espEnabled then
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
            if player.Character then
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
    if espEnabled then
        connectCharacterAdded(player)
    end
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

task.spawn(function()
    while true do
        task.wait(2)
        if espEnabled then
            updateESP()
        end
    end
end)

-- Aimlock Funktionen
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if distance <= 40 then
                local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local diff = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if diff < shortestDistance then
                        closestPlayer = player
                        shortestDistance = diff
                    end
                end
            end
        end
    end

    return closestPlayer
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if aimEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
            end
        end)

        UserInputService.InputEnded:Connect(function(inputEnded)
            if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
                if connection then connection:Disconnect() end
            end
        end)
    end
end)

aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimButton.Text = aimEnabled and "Aimlock AUS" or "Aimlock AN"
end)

-- Bei Respawn GUI erhalten
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    screenGui.Parent = PlayerGui
end)
