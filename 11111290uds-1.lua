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
frame.Size = UDim2.new(0, 200, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggleESPButton = Instance.new("TextButton", frame)
toggleESPButton.Size = UDim2.new(1, -20, 0, 40)
toggleESPButton.Position = UDim2.new(0, 10, 0, 40)
toggleESPButton.Text = "ESP AN"
toggleESPButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleESPButton.TextColor3 = Color3.new(1, 1, 1)
toggleESPButton.Font = Enum.Font.SourceSans
toggleESPButton.TextSize = 18

local aimlockButton = Instance.new("TextButton", frame)
aimlockButton.Size = UDim2.new(1, -20, 0, 40)
aimlockButton.Position = UDim2.new(0, 10, 0, 90)
aimlockButton.Text = "Aimlock AN"
aimlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
aimlockButton.TextColor3 = Color3.new(1, 1, 1)
aimlockButton.Font = Enum.Font.SourceSans
aimlockButton.TextSize = 18

-- ESP
local espEnabled = false
local highlights = {}

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance <= 40 then
				if espEnabled and not highlights[player] then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(255, 0, 0)
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.Adornee = player.Character
					hl.Parent = player.Character
					highlights[player] = hl
				elseif not espEnabled and highlights[player] then
					highlights[player]:Destroy()
					highlights[player] = nil
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

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(1)
		if espEnabled then updateESP() end
	end)
end)

RunService.Stepped:Connect(function()
	pcall(updateESP)
end)

-- Aimlock + Silent Aim
local aimlockEnabled = false
local rightMouseHeld = false
local target = nil
local aimUpdateInterval = 2
local lastUpdate = tick()
local mouse = LocalPlayer:GetMouse()
local silentHook

local function getClosestEnemy()
	local closest = nil
	local shortestDistance = 40
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance < shortestDistance then
				closest = player
				shortestDistance = distance
			end
		end
	end
	return closest
end

local function enableSilentAim()
	if getfenv().hookmetamethod and not silentHook then
		silentHook = hookmetamethod(game, "__index", newcclosure(function(self, key)
			if not checkcaller() and aimlockEnabled and rightMouseHeld and self == mouse and (key == "Hit" or key == "Target") and target and target.Character then
				local hrp = target.Character:FindFirstChild("HumanoidRootPart")
				if hrp then return hrp.CFrame end
			end
			return getrawmetatable(game).__index(self, key)
		end))
	end
end

enableSilentAim() -- Hook wird immer vorbereitet, aber nur mit Bedingung aktiv

-- Buttons (nicht mehr nötig aber bleibt als Visual)
toggleESPButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	toggleESPButton.Text = espEnabled and "ESP AUS" or "ESP AN"
end)

aimlockButton.MouseButton1Click:Connect(function()
	aimlockEnabled = not aimlockEnabled
	aimlockButton.Text = aimlockEnabled and "Aimlock AUS" or "Aimlock AN"
end)

-- Taste T = beide toggeln
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.T then
		espEnabled = not espEnabled
		aimlockEnabled = not aimlockEnabled
		toggleESPButton.Text = espEnabled and "ESP AUS" or "ESP AN"
		aimlockButton.Text = aimlockEnabled and "Aimlock AUS" or "Aimlock AN"
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		rightMouseHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		rightMouseHeld = false
	end
end)

RunService.Heartbeat:Connect(function()
	if aimlockEnabled and tick() - lastUpdate >= aimUpdateInterval then
		target = getClosestEnemy()
		lastUpdate = tick()
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	wait(1)
	if espEnabled then updateESP() end
end)
