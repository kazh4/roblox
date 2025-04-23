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
frame.Position = UDim2.new(1, -220, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KAZHA Menü"
title.TextColor3 = Color3.fromRGB(120, 90, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggleESPButton = Instance.new("TextButton", frame)
toggleESPButton.Size = UDim2.new(1, -20, 0, 40)
toggleESPButton.Position = UDim2.new(0, 10, 0, 40)
toggleESPButton.Text = "ESP: Taste [T]"
toggleESPButton.BackgroundColor3 = Color3.fromRGB(80, 40, 130)
toggleESPButton.TextColor3 = Color3.fromRGB(180, 150, 255)
toggleESPButton.Font = Enum.Font.SourceSans
toggleESPButton.TextSize = 18

toggleESPButton.MouseButton1Click:Connect(function() end) -- Deaktiviert

local aimlockButton = Instance.new("TextButton", frame)
aimlockButton.Size = UDim2.new(1, -20, 0, 40)
aimlockButton.Position = UDim2.new(0, 10, 0, 90)
aimlockButton.Text = "Aimlock: Rechte Maus"
aimlockButton.BackgroundColor3 = Color3.fromRGB(80, 40, 130)
aimlockButton.TextColor3 = Color3.fromRGB(180, 150, 255)
aimlockButton.Font = Enum.Font.SourceSans
aimlockButton.TextSize = 18

aimlockButton.MouseButton1Click:Connect(function() end) -- Deaktiviert

-- ESP
local espEnabled = false
local highlights = {}

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance <= 300 then
				if espEnabled and not highlights[player] then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(0, 100, 255)
					hl.OutlineColor = Color3.fromRGB(0, 180, 255)
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

-- Aimlock
local aimlockEnabled = false
local aiming = false
local target = nil
local aimUpdateInterval = 2
local lastUpdate = tick()

local function getClosestEnemy()
	local closest = nil
	local shortestDistance = 40
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local distance = (player.Character.Head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance < shortestDistance then
				closest = player
				shortestDistance = distance
			end
		end
	end
	return closest
end

local function enableAimlock()
	if getfenv().hookmetamethod then
		local Mouse = LocalPlayer:GetMouse()
		local OldIndex
		OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
			if not checkcaller() and aiming and self == Mouse and (Index == "Hit" or Index == "Target") and target and target.Character then
				local head = target.Character:FindFirstChild("Head")
				if head then return head.CFrame end
			end
			return OldIndex(self, Index)
		end))
	end
end
enableAimlock()

-- Tasteneingaben
local keybindActivated = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
		keybindActivated = true
		espEnabled = true
		aimlockEnabled = true
	end
	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 and aimlockEnabled then
		aiming = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(1)
		if espEnabled then updateESP() end
	end)
end)

LocalPlayer.CharacterAdded:Connect(function()
	wait(1)
	if keybindActivated then
		espEnabled = true
		aimlockEnabled = true
	end
end)

RunService.Heartbeat:Connect(function()
	if espEnabled then pcall(updateESP) end
	if aimlockEnabled and aiming and tick() - lastUpdate >= aimUpdateInterval then
		target = getClosestEnemy()
		lastUpdate = tick()
	end
end)

