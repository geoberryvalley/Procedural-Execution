local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Gameplay.Constants)

local walls = script.Parent:GetChildren()

Workspace:GetAttributeChangedSignal(Constants.PHASE_ATTRIBUTE):Connect(function()
	local phase = Workspace:GetAttribute(Constants.PHASE_ATTRIBUTE)
	if phase == Constants.PHASE_EXECUTION then
		for _, wall in pairs(walls) do
			if wall:IsA("BasePart") then
				wall.Transparency = 1
				wall.CanCollide = false
				wall.CanQuery = false
				wall.CanTouch = false
			end
		end
	else
		for _, wall in pairs(walls) do
			if wall:IsA("BasePart") then
				wall.Transparency = 1
				wall.CanCollide = true
				wall.CanQuery = true
				wall.CanTouch = true
			end
		end
	end
end)