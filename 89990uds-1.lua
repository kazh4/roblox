-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "KAZHA"

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

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.Text = "ESP AN"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 18

local aimlockButton = Instance.new("TextButton", frame)
aimlockButton.Size = UDim2.new(1, -20, 0, 40)
aimlockButton.Position = UDim2.new(0, 10, 0, 90)
aimlockButton.Text = "Aimlock"
aimlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
aimlockButton.TextColor3 = Color3.new(1,1,1)
aimlockButton.Font = Enum.Font.SourceSans
aimlockButton.TextSize = 18

local bothToggleLabel = Instance.new("TextLabel", frame)
bothToggleLabel.Size = UDim2.new(1, -20, 0, 20)
bothToggleLabel.Position = UDim2.new(0, 10, 0, 135)
bothToggleLabel.Text = "both = T"
bothToggleLabel.TextColor3 = Color3.new(1,1,1)
bothToggleLabel.BackgroundTransparency = 1
bothToggleLabel.Font = Enum.Font.SourceSans
bothToggleLabel.TextSize = 14

-- States
local espEnabled = false
local aimlockEnabled = false
local highlights = {}
local characterConnections = {}
local Aiming = false
local Target = nil

-- ESP
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local distance = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
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
                elseif highlights[player] then
                    highlights[player]:Destroy()
                    highlights[player] = nil
                end
            end
        end
    end
end

local function connectCharacterAdded(player)
    if player ~= LocalPlayer and not characterConnections[player] then
        characterConnections[player] = player.CharacterAdded:Connect(function(char)
            wait(1)
            if espEnabled and char:FindFirstChild("HumanoidRootPart") then
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
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Adornee = player.Character
                hl.Parent = player.Character
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

-- Aiming
local function getClosestPlayer(maxDistance)
    local closest = nil
    local shortest = maxDistance or 40
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                closest = player
                shortest = dist
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimlockEnabled then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Aiming and aimlockEnabled then
        Target = getClosestPlayer(40)
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local head = Target.Character.Head
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position)
        end
    end
end)

-- GUI Buttons
toggleButton.MouseButton1Click:Connect(toggleESP)
aimlockButton.MouseButton1Click:Connect(function()
    aimlockEnabled = not aimlockEnabled
    aimlockButton.Text = aimlockEnabled and "Aimlock (an)" or "Aimlock"
end)

-- T Key Toggle Both
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.T then
        espEnabled = not espEnabled
        aimlockEnabled = espEnabled
        toggleButton.Text = espEnabled and "ESP AUS" or "ESP AN"
        aimlockButton.Text = aimlockEnabled and "Aimlock (an)" or "Aimlock"
        if not espEnabled then
            for _, hl in pairs(highlights) do
                hl:Destroy()
            end
            highlights = {}
        end
    end
end)

-- Update Loop
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