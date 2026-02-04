-- LocalScript
local tool = script.Parent
local remoteEvent = game.ReplicatedStorage.Loadout.ItemRemotes:WaitForChild("ShieldEquipped")

local smol = Vector3.new(3,1,0.5)
local big = Vector3.new(5,6,0.5)

-- Connect the Equipped event
tool.Equipped:Connect(function()
	remoteEvent:FireServer(true)
	--task.wait(0.5)
	--tool.Handle.Size = big
end)

-- Connect the Unequipped event
tool.Unequipped:Connect(function()
	remoteEvent:FireServer(false)
	--tool.Handle.Size = smol
end)