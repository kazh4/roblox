-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
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

-- ESP Button
local toggleESPButton = Instance.new("TextButton")
toggleESPButton.Size = UDim2.new(1, -20, 0, 40)
toggleESPButton.Position = UDim2.new(0, 10, 0, 40)
toggleESPButton.Text = "ESP AN"
toggleESPButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleESPButton.TextColor3 = Color3.new(1,1,1)
toggleESPButton.Font = Enum.Font.SourceSans
toggleESPButton.TextSize = 18
toggleESPButton.Parent = frame

-- Aimlock Button
local aimlockButton = Instance.new("TextButton")
aimlockButton.Size = UDim2.new(1, -20, 0, 40)
aimlockButton.Position = UDim2.new(0, 10, 0, 90)
aimlockButton.Text = "Aimlock AN"
aimlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
aimlockButton.TextColor3 = Color3.new(1,1,1)
aimlockButton.Font = Enum.Font.SourceSans
aimlockButton.TextSize = 18
aimlockButton.Parent = frame

-- ESP & Aimlock Setup
local espEnabled = false
local aimlockEnabled = false
local highlights = {}
local currentTarget = nil

local function isEnemy(player)
	-- Passe dies ggf. an dein Team-System an
	return player.Team ~= LocalPlayer.Team
end

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance <= 300 and isEnemy(player) then
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

-- Aimlock Funktion
local function updateAimlock()
	local closestPlayer = nil
	local closestDistance = 40
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and isEnemy(player) and player.Character and player.Character:FindFirstChild("Head") then
			local distance = (player.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestPlayer = player
			end
		end
	end
	currentTarget = closestPlayer
	if currentTarget then
		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, currentTarget.Character.Head.Position)
	end
end

-- ESP Button Click
toggleESPButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	toggleESPButton.Text = espEnabled and "ESP AUS" or "ESP AN"
	updateESP()
end)

-- Aimlock Button Click
aimlockButton.MouseButton1Click:Connect(function()
	aimlockEnabled = not aimlockEnabled
	aimlockButton.Text = aimlockEnabled and "Aimlock AUS" or "Aimlock AN"
end)

-- Update alle 2 Sekunden
RunService.Stepped:Connect(function()
	if espEnabled then
		updateESP()
	end
	if aimlockEnabled then
		updateAimlock()
	end
end)

-- Handle respawn
local function onCharacterAdded()
	wait(1)
	updateESP()
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Neue Spieler support
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(1)
		updateESP()
	end)
end)