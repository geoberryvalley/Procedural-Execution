--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local RunService = game:GetService("RunService")
--local Workspace = game:GetService("Workspace")

--local Players = game:GetService("Players")

--local player = Players.LocalPlayer
--local character = player.Character or player.CharacterAdded:Wait()
--local humanoid = character:WaitForChild("Humanoid")

--local Constants = require(ReplicatedStorage.Blaster.Constants)
--local lerp = require(ReplicatedStorage.Utility.lerp)

--local MoveSpeedController = {}

--local speedMods = {}

--function MoveSpeedController.addSpeedMult(name: string, mult: number)
--	if (speedMods[name] ~= nil) then
--		humanoid.WalkSpeed /= speedMods[name]
--	end
--	speedMods[name] = mult
--	humanoid.WalkSpeed *= mult
--	--print(speedMods)
--end

--function MoveSpeedController.removeSpeedMult(name: string)
--	if (speedMods[name] ~= nil) then
--		humanoid.WalkSpeed /= speedMods[name]
--		speedMods[name] = nil
--	end
--end

--function MoveSpeedController.reset()
--	character = player.Character or player.CharacterAdded:Wait()
--	humanoid = character:WaitForChild("Humanoid")
--	humanoid.WalkSpeed = Constants.DEFAULT_WALKSPEED
--	speedMods = {}
--end

--return MoveSpeedController
