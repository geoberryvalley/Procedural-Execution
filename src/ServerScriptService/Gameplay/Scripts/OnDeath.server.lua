local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local remotes = ReplicatedStorage.Gameplay.Remotes
local forceCameraRemote = remotes.ForceCamera
local eliminatedRemote = remotes.Eliminated

local function onPlayerAdded(player)
	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.BreakJointsOnDeath = false
		local function onDied()
			forceCameraRemote:FireClient(player, true, false)
			task.wait(1)
			humanoid.Parent:Destroy()--MoveTo(Vector3.new(0,200,0))
		end

		humanoid.Died:Connect(onDied)
	end

	player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(onPlayerAdded)