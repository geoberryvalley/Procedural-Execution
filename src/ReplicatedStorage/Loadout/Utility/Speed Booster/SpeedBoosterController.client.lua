-- LocalScript
local tool = script.Parent
local remoteEvent = game.ReplicatedStorage.Loadout.ItemRemotes:WaitForChild("SpeedBoosterUsed")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Connect the Equipped event
tool.Activated:Connect(function()
	remoteEvent:FireServer()
end)

