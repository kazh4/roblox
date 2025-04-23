-- ESP & Silent Aimlock GUI Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KAZHA"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggleESPButton = Instance.new("TextButton", frame)
toggleESPButton.Size = UDim2.new(1, -20, 0, 40)
toggleESPButton.Position = UDim2.new(0, 10, 0, 40)
toggleESPButton.Text = "ESP AN"
toggleESPButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleESPButton.TextColor3 = Color3.new(1,1,1)
toggleESPButton.Font = Enum.Font.SourceSans
toggleESPButton.TextSize = 18

local toggleAimlockButton = Instance.new("TextButton", frame)
toggleAimlockButton.Size = UDim2.new(1, -20, 0, 40)
toggleAimlockButton.Position = UDim2.new(0, 10, 0, 90)
toggleAimlockButton.Text = "Aimlock AN"
toggleAimlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleAimlockButton.TextColor3 = Color3.new(1,1,1)
toggleAimlockButton.Font = Enum.Font.SourceSans
toggleAimlockButton.TextSize = 18

-- Einstellungen
local espEnabled = false
local aimlockEnabled = false
local highlights = {}
local currentTarget = nil

-- ESP Funktion
local function updateESP()
    for player, highlight in pairs(highlights) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if highlight then
                highlight:Destroy()
                highlights[player] = nil
            end
        else
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if espEnabled and distance <= 300 then
                if not highlight then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Adornee = player.Character
                    hl.Parent = player.Character
                    highlights[player] = hl
                end
            else
                if highlight then
                    highlight:Destroy()
                    highlights[player] = nil
                end
            end
        end
    end
end

-- Aimlock Funktion
local function findClosestTarget()
    local closest = nil
    local shortestDistance = 40
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance <= shortestDistance then
                shortestDistance = distance
                closest = player
            end
        end
    end
    return closest
end

local function lockOnTarget()
    currentTarget = findClosestTarget()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and aimlockEnabled then
        lockOnTarget()
    end
end)

RunService.RenderStepped:Connect(function()
    if aimlockEnabled and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character.Head.Position)
    end
end)

-- Button-Klicks

toggleESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleESPButton.Text = espEnabled and "ESP AUS" or "ESP AN"
end)

toggleAimlockButton.MouseButton1Click:Connect(function()
    aimlockEnabled = not aimlockEnabled
    toggleAimlockButton.Text = aimlockEnabled and "Aimlock AUS" or "Aimlock AN"
end)

-- Spieler beobachten
local function trackPlayer(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if espEnabled then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Adornee = player.Character
            hl.Parent = player.Character
            highlights[player] = hl
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        trackPlayer(player)
    end
end

Players.PlayerAdded:Connect(trackPlayer)

-- Aktualisierungsschleife
while true do
    updateESP()
    task.wait(2)
end
