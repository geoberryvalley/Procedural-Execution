local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.Gameplay.Remotes
local forceCameraRemote = remotes.ForceCamera

local function spawnCharacters()
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			player:LoadCharacter()
			forceCameraRemote:FireClient(player, false, true)
		end)
	end
end

return spawnCharacters
