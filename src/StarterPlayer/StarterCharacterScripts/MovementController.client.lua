local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Players = game:GetService("Players")

local character = script.Parent
local humanoid = character.Humanoid

local Constants = require(ReplicatedStorage.Blaster.Constants)
local lerp = require(ReplicatedStorage.Utility.lerp)

local speedBindable = ReplicatedStorage.Gameplay.Remotes.SpeedMult
local speedRemote = ReplicatedStorage.Gameplay.Remotes.SpeedMultServer

local speedMods = {}

function addSpeedMult(name: string, mult: number)
	if (speedMods[name] ~= nil) then
		humanoid.WalkSpeed /= speedMods[name]
	end
	speedMods[name] = mult
	humanoid.WalkSpeed *= mult
	--print(speedMods)
end

function removeSpeedMult(name: string)
	if (speedMods[name] ~= nil) then
		humanoid.WalkSpeed /= speedMods[name]
		speedMods[name] = nil
	end
end

function reset()
	humanoid.WalkSpeed = Constants.DEFAULT_WALKSPEED
	speedMods = {}
end

function doStuff(funcName: string, name: string, mult: number)
	if funcName == "reset" then
		reset()
	elseif funcName == "addSpeedMult" then
		addSpeedMult(name, mult)
	elseif funcName == "removeSpeedMult" then
		removeSpeedMult(name)
	end
end

speedBindable.Event:Connect(doStuff)
speedRemote.OnClientEvent:Connect(doStuff)