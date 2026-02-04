local tool = script.Parent
local handle = tool.Handle

local remoteEvent = game.ReplicatedStorage.Loadout.ItemRemotes.GrenadeThrown
local camera = workspace.CurrentCamera

tool.Activated:Connect(function()
	
	remoteEvent:FireServer(camera.CFrame,tool.Name)
	
	tool:Destroy()

end)