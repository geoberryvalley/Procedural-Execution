-- ServerScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shieldEquippedEvent = ReplicatedStorage.Loadout.ItemRemotes:WaitForChild("SpeedBoosterUsed")
local UpdateSpeedEvent = ReplicatedStorage.Gameplay.Remotes.SpeedMultServer



-- Connect to the RemoteEvent
shieldEquippedEvent.OnServerEvent:Connect(function(player)
	local tool = player.Character:FindFirstChild("Speed Booster")
	tool:Destroy()
	UpdateSpeedEvent:FireClient(player, "addSpeedMult", "SpeedBooster", 1.5)
	task.wait(5)
	UpdateSpeedEvent:FireClient(player, "removeSpeedMult", "SpeedBooster")
end)