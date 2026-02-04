local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Gameplay.Constants)

local remotes = ReplicatedStorage.Gameplay.Remotes
local setScanningAirRemote = remotes.SetScanningAir

local highlight = script.DefenderScanned

local touchingPartsList = {}

local function onTouched(hit)
	task.wait(0.1)
	if hit.Name == "HumanoidRootPart" and hit.Parent:FindFirstChild("Humanoid") then
		if not table.find(touchingPartsList, hit.Parent.Name) and Players:GetPlayerFromCharacter(hit.Parent).Team == Teams.Defense then
			table.insert(touchingPartsList, hit.Parent.Name)
			--add the highlight
			if not hit.Parent:FindFirstChildWhichIsA("Highlight") then
				local newHighlight = highlight:Clone()
				newHighlight.Parent = hit.Parent
			end
		end
	end
end

local function onTouchEnded(hit)
	if table.find(touchingPartsList, hit.Parent.Name) then
		table.remove(touchingPartsList, table.find(touchingPartsList, hit.Parent.Name))
		--after 300ms, remove highlight if they are still not in it
		task.defer(function()
			task.wait(0.3)
			if not table.find(touchingPartsList, hit.Parent.Name) and hit.Parent:FindFirstChildWhichIsA("Highlight") then
				hit.Parent:FindFirstChildWhichIsA("Highlight"):Destroy()
			end
		end)
	end
end

for i,v : BasePart in pairs(Workspace.ScanningAirEdge:GetChildren()) do
	v.Touched:Connect(onTouched)
	v.TouchEnded:Connect(onTouchEnded)
end

setScanningAirRemote.Event:Connect(function()
	touchingPartsList = {}
	for i,v in pairs(Workspace.RandomlyGeneratedMap["ScanAirFolder"]:GetChildren()) do
		v.Touched:Connect(onTouched)
		v.TouchEnded:Connect(onTouchEnded)
	end
end)

Workspace:GetAttributeChangedSignal(Constants.PHASE_ATTRIBUTE):Connect(function()
	local curPhase = Workspace:GetAttribute(Constants.PHASE_ATTRIBUTE)
	if curPhase == Constants.PHASE_PREP then
		task.wait(1) --give it some time to load
		for i,v : BasePart in pairs(Workspace.ScanningAirEdge:GetChildren()) do
			v.CanCollide = true
		end
		for i,v in pairs(Workspace.RandomlyGeneratedMap["ScanAirFolder"]:GetChildren()) do
			v.CanCollide = true
		end
	elseif curPhase == Constants.PHASE_EXECUTION then
		for i,v : BasePart in pairs(Workspace.ScanningAirEdge:GetChildren()) do
			v.CanCollide = false
		end
		for i,v in pairs(Workspace.RandomlyGeneratedMap["ScanAirFolder"]:GetChildren()) do
			v.CanCollide = false
		end
	end
end)