local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KAZHA"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 180)
frame.Position = UDim2.new(1, -270, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 0, 60) -- Dunkles Lila
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.fromRGB(200, 140, 255) -- Helllila
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 26

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -10, 0, 120)
info.Position = UDim2.new(0, 5, 0, 50)
info.Text = "Taste [T] = ESP + Aimlock\nRechte Maustaste = Aimlock halten"
info.TextColor3 = Color3.fromRGB(200, 140, 255)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.Font = Enum.Font.SourceSans
info.TextSize = 18

-- ESP
local espEnabled = false
local highlights = {}

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if espEnabled then
				if not highlights[player] then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(255, 0, 255) -- Pink
					hl.OutlineColor = Color3.new(1, 1, 1)
					hl.Adornee = player.Character
					hl.Parent = player.Character
					highlights[player] = hl
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

local function cleanupESP()
	for player, hl in pairs(highlights) do
		if hl then
			hl:Destroy()
			highlights[player] = nil
		end
	end
end

-- Aimlock
local aimEnabled = false
local holdingMouse = false
local currentTarget = nil

local function getClosestEnemy()
	local closest, shortest = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local distance = (head.Position - LocalPlayer.Character.Head.Position).Magnitude
			if distance < shortest then
				shortest = distance
				closest = player
			end
		end
	end
	return closest
end

local function applySilentAim()
	local mouse = LocalPlayer:GetMouse()
	local __index
	__index = hookmetamethod(game, "__index", newcclosure(function(self, key)
		if self == mouse and (key == "Hit" or key == "Target") and holdingMouse and currentTarget and currentTarget.Character then
			local head = currentTarget.Character:FindFirstChild("Head")
			if head then
				return key == "Hit" and head.CFrame or head
			end
		end
		return __index(self, key)
	end))
end

applySilentAim()

-- Toggling
local toggled = false

local function toggleAll()
	toggled = not toggled
	espEnabled = toggled
	aimEnabled = toggled

	if not toggled then
		cleanupESP()
	end
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.T then
		toggleAll()
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		holdingMouse = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		holdingMouse = false
	end
end)

-- Update ESP and Aimlock Loop
RunService.RenderStepped:Connect(function()
	if espEnabled then
		pcall(updateESP)
	end

	if aimEnabled and holdingMouse then
		currentTarget = getClosestEnemy()
	end
end)

-- Respawn Support
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
