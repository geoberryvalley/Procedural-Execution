local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGUI = game:GetService("StarterGui")

local NeoHotbar = require(script.Parent.NeoHotbarLoader.NeoHotbar)

local Constants = require(ReplicatedStorage.Gameplay.Constants)

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local flashbangScreen = player.PlayerGui:WaitForChild("FlashbangGUI")


local roofFolder = workspace.Roof

local FlashbangRemote = ReplicatedStorage.Loadout.ItemRemotes.FlashbangHit
local ForcedCameraRemote = ReplicatedStorage.Gameplay.Remotes.ForceCamera



--flashbang
FlashbangRemote.OnClientEvent:Connect(function(percentFlashed: number)
	camera = workspace.CurrentCamera
	percentFlashed = percentFlashed*percentFlashed
	print("flashed",percentFlashed)

	local randomUnitVector = Vector3.new(math.random()*2-1,math.random()*2-1,math.random()*2-1)*percentFlashed
	camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position+camera.CFrame.LookVector + randomUnitVector) --change the direction of lookat to make it turn
	flashbangScreen.Enabled = true
	task.wait(3 * percentFlashed)
	flashbangScreen.Enabled = false
end)


--map view
local originalTransparency = {}

local function checkPart(part, hide : boolean)
	for a,b in pairs(part:GetChildren()) do
		checkPart(b, hide)
	end
	if part:IsA("BasePart") or part:IsA("Decal") then
		if hide then
			if not originalTransparency[part] then
				originalTransparency[part] = part.Transparency
			end
			part.Transparency = 1
		else --show
			if originalTransparency[part] then
				part.Transparency = originalTransparency[part]
				originalTransparency[part] = nil
			end
		end
	end
end

local function hideShowEnemies(hide : boolean)
	--hide the roof
	checkPart(roofFolder, hide)
	--TODO fix the code to work with opening and closing doors
	----hide the green doors
	--for i, v in pairs(workspace.RandomlyGeneratedMap:FindFirstChild("WallFolder"):GetChildren()) do
	--	if v:IsA("Model") and (v.Name == "RegularGreenDoor" or v.Name == "DoubleGreenDoor") then
	--		for a,b in pairs(v:GetChildren()) do
	--			if b:IsA("BasePart") and b.Name == "GreenDoor" then
	--				checkPart(b, hide)
	--			end
	--		end
	--	end
	--end
	--hide the players
	for i,v in pairs(Players:GetPlayers()) do
		if v.Team ~= player.Team then
			local char = v.Character
			if char then
				checkPart(char, hide)
				checkPart(v.Backpack, hide)
			end
		end
	end

	for part,trans in pairs(originalTransparency) do --remove parts that no longer exist
		if not part then
			originalTransparency[part] = nil
		elseif not part.Parent then
			originalTransparency[part] = nil
		end
	end
end

local isInMapView = false
local canChange = true

local selfHighlight = Instance.new("Highlight")
selfHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
selfHighlight.FillTransparency = 1
selfHighlight.OutlineColor = Color3.new(255,255,255)
selfHighlight.OutlineTransparency = 0

local function enterMapView()
	print("entering map view")
	if isInMapView then
		print("nvm already in map view")
		return nil
	end
	hideShowEnemies(true)
	player.PlayerGui.LoadoutGui.Enabled = false
	camera.CameraType = Enum.CameraType.Scriptable
	--camera.CFrame = CFrame.new(workspace.Lobby.CameraPart.Position, workspace.Lobby.CameraTarget.Position)
	camera.CFrame = CFrame.new(workspace.MapViewPart.Position, workspace.Floor.Position)

	local character = player.Character
	if character then
		local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			humanoid:UnequipTools()
			--StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			NeoHotbar:SetEnabled(false)
			selfHighlight.Parent = player.Character

		end
	end

	camera.CameraSubject = workspace.Floor
	isInMapView = true
end

local function exitMapView()
	print("exiting map view")
	if not isInMapView then
		print("nvm already out of map view")
		return nil
	end
	hideShowEnemies(false)


	local character = player.Character
	--this if statement logic is weird and should be fixed
	if workspace:GetAttribute(Constants.PHASE_ATTRIBUTE) ~= Constants.PHASE_EXECUTION and #player.Backpack:GetChildren() == 0 then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(workspace.Lobby.CameraPart.Position, workspace.Lobby.CameraTarget.Position)
		player.PlayerGui.LoadoutGui.Enabled = true
	elseif character then
		local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
			camera.CFrame = player.Character:GetPivot()

			selfHighlight.Parent = nil
			NeoHotbar:SetEnabled(true)
		end
	else --if character doesn't exist, set camera to lobby camera
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(workspace.Lobby.CameraPart.Position, workspace.Lobby.CameraTarget.Position)
	end

	isInMapView = false
end

UserInputService.InputBegan:Connect(function(input, _gameProcessed)
	if input.KeyCode == Enum.KeyCode.M then
		if isInMapView and canChange then
			exitMapView()
		else
			enterMapView()
		end
	end
end)

ForcedCameraRemote.OnClientEvent:Connect(function(emv: boolean, cc: boolean)
	canChange = cc
	if emv then
		enterMapView()
	else
		exitMapView()
	end
end)

--some more stuff for when you load in
task.wait(0.5)
if workspace:GetAttribute(Constants.PHASE_ATTRIBUTE) == Constants.PHASE_EXECUTION then
	enterMapView()
else
	enterMapView()
	exitMapView()
end