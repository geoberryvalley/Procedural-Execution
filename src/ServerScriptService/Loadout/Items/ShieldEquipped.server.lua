-- ServerScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shieldEquippedEvent = ReplicatedStorage.Loadout.ItemRemotes:WaitForChild("ShieldEquipped")
local UpdateSpeedEvent = ReplicatedStorage.Gameplay.Remotes.SpeedMultServer

local smol = Vector3.new(3,1,0.5)
local big = Vector3.new(6,8,0.5)

-- Connect to the RemoteEvent
shieldEquippedEvent.OnServerEvent:Connect(function(player, onoff)
	local tool = player.Character:FindFirstChild("Shield")
	if tool and onoff then
		tool.Handle.Size = smol
		UpdateSpeedEvent:FireClient(player, "addSpeedMult", "ShieldEquipped", 0.7)
		task.wait(0.5)
		tool.Handle.Size = big
	elseif not onoff then
		UpdateSpeedEvent:FireClient(player, "removeSpeedMult", "ShieldEquipped")
	end
end)