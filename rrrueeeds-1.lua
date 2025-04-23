local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "KAZHA"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 170) -- etwas höher für neuen Button
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.Text = "ESP AN"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 18

local lookButton = Instance.new("TextButton", frame)
lookButton.Size = UDim2.new(1, -20, 0, 40)
lookButton.Position = UDim2.new(0, 10, 0, 90)
lookButton.Text = "Auf Kopf schauen"
lookButton.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
lookButton.TextColor3 = Color3.new(1,1,1)
lookButton.Font = Enum.Font.SourceSans
lookButton.TextSize = 16

local espEnabled = false
local highlights = {}
local characterConnections = {}

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
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

lookButton.MouseButton1Click:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local camPos = head.Position + Vector3.new(0, 2, 8) -- leicht versetzt, damit du "draufguckst"
            Camera.CFrame = CFrame.new(camPos, head.Position)
            break -- Nur den ersten gültigen Spieler ansehen
        end
    end
end)

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
        wait(2)
        if espEnabled then
            updateESP()
        end
    end
end)
