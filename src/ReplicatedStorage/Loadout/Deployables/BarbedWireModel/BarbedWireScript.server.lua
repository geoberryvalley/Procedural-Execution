local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local BarbedWirePlacedEvent = ReplicatedStorage.Loadout.ItemRemotes:WaitForChild("BarbedWirePlaced")

local UpdateSpeedEvent = ReplicatedStorage.Gameplay.Remotes.SpeedMultServer
local Constants = require(ReplicatedStorage.Blaster.Constants)

local bwm = script.Parent
local bw = bwm.BarbedWire
local invis = bwm.BarbedWireHitbox
local sound = bwm.Sound

CollectionService:AddTag(bw, Constants.RAY_EXCLUDE_TAG)
CollectionService:AddTag(invis, Constants.RAY_EXCLUDE_TAG)

local touchingPartsList = {}

invis.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if not table.find(touchingPartsList, hit.Parent.Name) then
			table.insert(touchingPartsList, hit.Parent.Name)
			UpdateSpeedEvent:FireClient(Players:GetPlayerFromCharacter(hit.Parent), "addSpeedMult", "BarbedWire", 0.4)
			sound:Play()
		end
	end
end)

invis.TouchEnded:Connect(function(hit)

	if hit.Parent:FindFirstChild("Humanoid") then
		if table.find(touchingPartsList, hit.Parent.Name) then
			table.remove(touchingPartsList, table.find(touchingPartsList, hit.Parent.Name))
			UpdateSpeedEvent:FireClient(Players:GetPlayerFromCharacter(hit.Parent), "removeSpeedMult", "BarbedWire")
			if #touchingPartsList == 0 then
				sound:Stop()
			end
		end
	end
end)