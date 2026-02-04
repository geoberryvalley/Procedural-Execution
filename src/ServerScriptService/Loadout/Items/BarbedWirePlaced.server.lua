-- ServerScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local BarbedWirePlacedEvent = ReplicatedStorage.Loadout.ItemRemotes:WaitForChild("BarbedWirePlaced")

local UpdateSpeedEvent = ReplicatedStorage.Gameplay.Remotes.SpeedMultServer
local Constants = require(ReplicatedStorage.Blaster.Constants)



-- Connect to the RemoteEvent
BarbedWirePlacedEvent.OnServerEvent:Connect(function(player, cf : CFrame)
	local tool = player.Character:FindFirstChild("Barbed Wire")
	if tool then
		local barbedWire = ReplicatedStorage.Loadout.Deployables.BarbedWireModel:Clone()
		local posn = Vector3.new(cf.X, cf.Y-1, cf.Z)
		barbedWire:PivotTo(CFrame.new(posn, (posn + cf.LookVector))) 
		barbedWire.Parent = workspace.Placeables
		tool:Destroy()
	end
end)