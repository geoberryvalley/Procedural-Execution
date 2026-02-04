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

local CollectionService = game:GetService("CollectionService")
local Constants = require(ReplicatedStorage.Blaster.Constants)

local Deployables = ReplicatedStorage.Loadout.Deployables

GrenadeThrownEvent.OnServerEvent:Connect(function(player : Player, cameraCF : CFrame, name : string)
	player.Character:FindFirstChild(name):Destroy() --removed the grenade on the server side
	local alreadyHit = false
	local throwPart = Instance.new("Part")
	local sound = Instance.new("Sound")
	
	sound.Parent = throwPart
	
	throwPart.Size = Vector3.new(1,1,1)
	throwPart.Name = name
	throwPart.CanCollide = true
	throwPart.Parent = workspace
	throwPart:SetNetworkOwner(player)
	throwPart.CFrame = CFrame.new(cameraCF.Position + cameraCF.LookVector * 5, cameraCF.LookVector)
	throwPart.AssemblyLinearVelocity = (cameraCF.LookVector * 250)
	throwPart.CustomPhysicalProperties = PhysicalProperties.new(10,2,0,100,100)
	if name == "Fire Grenade" then
		throwPart.Color = Color3.new(1,0,0)
		task.wait(0.5)
		throwPart.Touched:Connect(function(hit)
			if alreadyHit then
				return nil
			end
			alreadyHit = true
			throwPart.Transparency = 1
			
			local fireClone = Deployables:FindFirstChild("Burning Fire"):Clone()
			fireClone.Parent = workspace.Placeables
			fireClone.Position = throwPart.Position
			fireClone:SetAttribute("OwnerName",player.Name)
			throwPart:Destroy()
		end)
	elseif name == "Smoke Grenade" then
		throwPart.Color = Color3.new(0.6,0.6,0.6)
		task.wait(1)
		
		throwPart.Transparency = 1
		local smokeClone = Deployables:FindFirstChild("SmokeOrb"):Clone()
		smokeClone.Parent = workspace.Placeables
		smokeClone.Position = throwPart.Position
		throwPart:Destroy()
		
	elseif name == "Foam Grenade" then
		throwPart.Color = Color3.new(0.6,0.6,0.6)
		task.wait(1)

		throwPart.Transparency = 1
		local smokeClone = Deployables:FindFirstChild("FoamOrb"):Clone()
		smokeClone.Parent = workspace.Placeables
		smokeClone.Position = throwPart.Position
		throwPart:Destroy()

	elseif name == "Utility Destroyer" then
		throwPart.Color = Color3.new(1, 0.9, 0.2)
		
		
		sound.SoundId = "rbxassetid://3802269741"
		local explosion = Instance.new("Explosion")
		local blastRadius = 5
		explosion.BlastPressure = 0
		explosion.BlastRadius = blastRadius
		explosion.DestroyJointRadiusPercent = 0
		
		explosion.Hit:Connect(function(hitPart)
			print("Utility Destroyer hit ",hitPart)


			if hitPart.Name == "BarbedWire" or hitPart.Name == "BarbedWireHitbox" or hitPart.Name == "GreenDoor" then
				hitPart:Destroy()
			end


		end)
		
		--detonate after 1 second
		task.wait(1)
		throwPart.Anchored = true
		throwPart.Transparency = 1
		explosion.Position = throwPart.Position
		explosion.Parent = workspace
		sound:Play()
		task.wait(1)
		throwPart:Destroy()
		explosion:Destroy()
		
		
	elseif name == "Flash Grenade" then
		throwPart.Color = Color3.new(0,0,0)
		--local explosion = Instance.new("Explosion")
		local maxRadius = 50
		--explosion.BlastPressure = 0
		--explosion.BlastRadius = blastRadius
		--explosion.DestroyJointRadiusPercent = 0
		--explosion.Visible = false
		sound.SoundId = "rbxassetid://5229833733"
		sound.Looped = true
		sound:Play()
		
		task.wait(1.5)
		--explosion.Position = throwPart.Position
		--explosion.Parent = workspace
		
		--raycasting for hits
		
		local rcParams = RaycastParams.new()
		rcParams.FilterDescendantsInstances = CollectionService:GetTagged(Constants.RAY_EXCLUDE_TAG)
		rcParams.FilterType = Enum.RaycastFilterType.Exclude
		
		local rayOrigin = throwPart.Position
		local rayDirections = {}
		for i, v in pairs(Players:GetPlayers()) do
			if v.Team ~= player.Team then --add the ray directions
				local rayDir = v.Character:GetPivot().Position - rayOrigin
				table.insert(rayDirections, rayDir)
			end
		end
		
		local hitHumanoidsList = {}
		
		for i, rd in pairs(rayDirections) do
			local rcRes = workspace:Raycast(rayOrigin,rd,rcParams)
			local hitPart = rcRes.Instance
			if hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid") then
				local humanoid = hitPart.Parent:FindFirstChild("Humanoid")
				if Players:GetPlayerFromCharacter(humanoid.Parent).Team ~= player.Team and not table.find(hitHumanoidsList, hitPart.Parent.Name) then
					table.insert(hitHumanoidsList, hitPart.Parent.Name)
					if (rcRes.Distance < maxRadius) then
						FlashbangHitEvent:FireClient(Players:GetPlayerFromCharacter(hitPart.Parent),1-(rcRes.Distance/maxRadius))
					end
				end

			end
		end
			
		--explosion.Hit:Connect(function(hitPart, distance)
		--	if hitPart.Parent:FindFirstChild("Humanoid") then
		--		local humanoid = hitPart.Parent:FindFirstChild("Humanoid")
		--		if Players:GetPlayerFromCharacter(humanoid.Parent).Team == Teams.Defense and not table.find(hitHumanoidsList, hitPart.Parent.Name) then
		--			table.insert(hitHumanoidsList, hitPart.Parent.Name)
		--			FlashbangHitEvent:FireClient(Players:GetPlayerFromCharacter(hitPart.Parent),1-(distance/blastRadius))
		--		end
				
		--	end
		--end)
		
		
		task.wait(1)
		throwPart:Destroy()
		--explosion:Destroy()
	elseif name == "Scan Grenade" then
		throwPart.Color = Color3.new(0,0,0)
		sound.SoundId = "rbxassetid://116750931446400"
		sound:Play()
		local explosion = Instance.new("Explosion")
		local blastRadius = 25
		explosion.BlastPressure = 0
		explosion.BlastRadius = blastRadius
		explosion.DestroyJointRadiusPercent = 0
		explosion.Visible = false

		local hitHumanoidsList = {}

		explosion.Hit:Connect(function(hitPart, distance)
			if hitPart.Parent:FindFirstChild("Humanoid") then
				local humanoid = hitPart.Parent:FindFirstChild("Humanoid")
				if ((not table.find(hitHumanoidsList, hitPart.Parent.Name)) and (Players:GetPlayerFromCharacter(humanoid.Parent).Team == player.Team)) then
					table.insert(hitHumanoidsList, hitPart.Parent.Name)
					local highlight = Instance.new("Highlight")
					highlight.Parent = humanoid.Parent
					highlight.FillTransparency = 0.5
					highlight.FillColor = Color3.new(1, 0, 0.74902)
					highlight.OutlineTransparency = 0
					task.wait(5)
					highlight:Destroy()
				end

			end
		end)

		task.wait(1)
		explosion.Position = throwPart.Position
		explosion.Parent = workspace
		task.wait(1)
		throwPart:Destroy()
		explosion:Destroy()
	end
end)

