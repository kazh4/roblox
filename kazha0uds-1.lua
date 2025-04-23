local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KAZHA"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(1, -220, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.fromRGB(100, 0, 150) -- Dunkles Lila
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 40)
statusLabel.Text = "ESP/Aimlock: AUS"
statusLabel.TextColor3 = Color3.fromRGB(200, 120, 255) -- Helles Lila
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 18

-- ESP + Aimlock Setup
local espEnabled = false
local aiming = false
local aimHeld = false
local target = nil
local highlights = {}

local function updateESP()
	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local char = player.Character
			local distance = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance <= 300 then
				if espEnabled and not highlights[player] then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(200, 120, 255) -- Helles Lila
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.Adornee = char
					hl.Parent = char
					highlights[player] = hl
				elseif not espEnabled and highlights[player] then
					highlights[player]:Destroy()
					highlights[player] = nil
				end
			elseif highlights[player] then
				highlights[player]:Destroy()
				highlights[player] = nil
			end
		end
	end
end

local function getClosestEnemy()
	local closest, shortest = nil, 40
	for _, player in Players:GetPlayers() do
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

-- Silent Aim (durch Wände, zielt auf Kopf)
local Mouse = LocalPlayer:GetMouse()
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__index
mt.__index = newcclosure(function(self, key)
	if not checkcaller() and self == Mouse and (key == "Hit" or key == "Target") and aiming and aimHeld and target and target.Character then
		local head = target.Character:FindFirstChild("Head")
		if head then
			return (key == "Hit") and head.CFrame or head
		end
	end
	return old(self, key)
end)

-- Aktivieren mit Taste T
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.T then
		espEnabled = true
		aiming = true
		statusLabel.Text = "ESP/Aimlock: AN"
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aimHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aimHeld = false
	end
end)

-- Respawn support
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(1)
		if espEnabled then updateESP() end
	end)
end)

LocalPlayer.CharacterAdded:Connect(function()
	wait(1)
	if espEnabled then updateESP() end
end)

-- Loops
RunService.Stepped:Connect(function()
	pcall(updateESP)
end)

RunService.Heartbeat:Connect(function()
	if aiming then
		target = getClosestEnemy()
	end
end)
