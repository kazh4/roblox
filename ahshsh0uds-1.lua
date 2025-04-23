-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "KAZHA"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 260, 0, 140)
frame.Position = UDim2.new(1, -280, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
frame.BackgroundTransparency = 0.7
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.fromRGB(100, 100, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

local toggleLabel = Instance.new("TextLabel", frame)
toggleLabel.Size = UDim2.new(1, 0, 0, 30)
toggleLabel.Position = UDim2.new(0, 0, 0, 50)
toggleLabel.Text = "ESP & Aimlock: Taste [T]"
toggleLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Font = Enum.Font.SourceSans
toggleLabel.TextSize = 20

-- VARIABLES
local espEnabled = false
local aimlockEnabled = false
local highlights = {}
local target = nil

-- ESP
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not highlights[player] and espEnabled then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 105, 180) -- pink
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Adornee = player.Character
                hl.Parent = player.Character
                highlights[player] = hl
            elseif highlights[player] and not espEnabled then
                highlights[player]:Destroy()
                highlights[player] = nil
            end
        end
    end
    -- Clean up highlights for players no longer valid
    for player, hl in pairs(highlights) do
        if not player.Parent or not espEnabled then
            hl:Destroy()
            highlights[player] = nil
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        updateESP()
    end)
end)

RunService.Stepped:Connect(function()
    pcall(updateESP)
end)

-- AIMLOCK
local function getClosestEnemy()
    local shortestDistance = math.huge
    local closest = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local distance = (player.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = player
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimlockEnabled then
        target = getClosestEnemy()
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        target = nil
    end
end)

local mouse = LocalPlayer:GetMouse()
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__index

mt.__index = newcclosure(function(self, key)
    if self == mouse and (key == "Hit" or key == "Target") and target and target.Character and target.Character:FindFirstChild("Head") then
        return target.Character.Head.CFrame
    end
    return oldNamecall(self, key)
end)

-- HOTKEY TOGGLE
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        espEnabled = not espEnabled
        aimlockEnabled = not aimlockEnabled
        updateESP()
    end
end)

-- RESPAWN HANDLING
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateESP()
end)