local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ServerScriptService = game:GetService("ServerScriptService")

local GrenadeThrownEvent = ReplicatedStorage.Loadout.ItemRemotes.GrenadeThrown
local FlashbangHitEvent = ReplicatedStorage.Loadout.ItemRemotes.FlashbangHit

local remotes = ReplicatedStorage.Gameplay.Remotes
local eliminatedRemote = remotes.Eliminated

local blasterEvents = ServerScriptService.Blaster.Events
local eliminatedEvent = blasterEvents.Eliminated

local fire = script.Parent
local sound = fire.Sound

sound:Play()
local isTouchingGround = false
local count = 0
while not isTouchingGround do
	local partsList = workspace:GetPartsInPart(fire)
	for i, v in ipairs(partsList) do
		if v.Name == "Floor" then
			isTouchingGround = true
		end
	end
	count = count + 1
	fire.Position = Vector3.new(fire.Position.X, fire.Position.Y - 1, fire.Position.Z)
	if count > 30 then
		return nil --idk i just want the script to die
	end
end

--deal dmg
local touchedHumanoids = {}

fire.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if not table.find(touchedHumanoids, hit.Parent.Humanoid) and hit.Parent.Humanoid.Health > 0 then
			table.insert(touchedHumanoids, hit.Parent.Humanoid)
		end
	end
end)

fire.TouchEnded:Connect(function(unhit)
	if unhit.Parent:FindFirstChild("Humanoid") then
		if table.find(touchedHumanoids, unhit.Parent.Humanoid) then
			table.remove(touchedHumanoids,table.find(touchedHumanoids, unhit.Parent.Humanoid))
		end
	end
end)
local endTime = time() + 10
while time() < endTime do
	task.wait(0.1)
	for i,v : Humanoid in ipairs(touchedHumanoids) do
		v:TakeDamage(4)
		if v.Health <= 0 then
			local name = if Players:GetPlayerFromCharacter(v.Parent) then Players:GetPlayerFromCharacter(v.Parent).DisplayName else v.Parent.Name
			local ownername = fire:GetAttribute("OwnerName")
			eliminatedRemote:FireClient(Players:FindFirstChild(ownername), name)
			eliminatedEvent:Fire(Players:FindFirstChild(ownername),v)
			table.remove(touchedHumanoids,table.find(touchedHumanoids, v))
		end
	end
end
fire:Destroy()