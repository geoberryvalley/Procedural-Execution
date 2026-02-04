local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadoutFolder = ReplicatedStorage:WaitForChild("Loadout")
local LoadoutEvent = LoadoutFolder:WaitForChild("LoadoutEvent")
local PrimaryFolder = LoadoutFolder:WaitForChild("Primary")
local SecondaryFolder = LoadoutFolder:WaitForChild("Secondary")
local GrenadeFolder = LoadoutFolder:WaitForChild("Grenades")
local UtilityFolder = LoadoutFolder:WaitForChild("Utility")
local OutfitFolder = LoadoutFolder:WaitForChild("Outfit")

local remotes = ReplicatedStorage.Gameplay.Remotes
local forceCameraRemote = remotes.ForceCamera


local Teams = game:GetService("Teams")

LoadoutEvent.OnServerEvent:Connect(function(plr : Player, Items : {}, OutfitName : string)
	local PrimaryClone = PrimaryFolder:FindFirstChild(Items[1]):Clone()
	local SecondaryClone = SecondaryFolder:FindFirstChild(Items[2]):Clone()
	local GrenadeClone = GrenadeFolder:FindFirstChild(Items[3]):Clone()
	local UtilityClone = UtilityFolder:FindFirstChild(Items[4]):Clone()
	local OutfitChosen = OutfitFolder:FindFirstChild(OutfitName)

	local chr = plr.Character
	local humanoid = chr:FindFirstChildWhichIsA("Humanoid")
	print("adding stuff to BP")
	PrimaryClone.Parent = plr.Backpack
	SecondaryClone.Parent = plr.Backpack
	GrenadeClone.Parent = plr.Backpack
	UtilityClone.Parent = plr.Backpack
	
	
	humanoid:ApplyDescription(OutfitChosen)
	forceCameraRemote:FireClient(plr,true,true) --if they autodeploy then, force them to look at the map first so we can reset their camera
	forceCameraRemote:FireClient(plr,false,true)
	
	--if plr.Team then
		
	--	local humDesc = Instance.new("HumanoidDescription")
	--	if humanoid then
	--		humDesc = humanoid:GetAppliedDescription()
	--	end
		
	--	if plr.Team == Teams.Attack then
	--		humDesc.FaceAccessory = 132461737652136
	--		humDesc.HairAccessory = "17106973177, 81702365357817"
	--		humDesc.HatAccessory = "12201400258, 14807612252"
	--		humDesc.FrontAccessory = "15177836845, 120831755877022"
	--		humDesc.Shirt = "90085550776901"
	--		humDesc.WaistAccessory = "18236504983"
	--		humDesc.Pants = 16465469514
	--	elseif plr.Team == Teams.Defense then
	--		humDesc.FaceAccessory = 14367720438
	--		humDesc.HairAccessory = "16452088230, 118056103257844"
	--		humDesc.HatAccessory = "17538288149,14082230741"
	--		humDesc.ShouldersAccessory = "18822024536"
	--		humDesc.FrontAccessory = "70452402452230, 84583571408714"
	--		humDesc.WaistAccessory = "15893944730"
	--		humDesc.Shirt = 117387095595523
	--		humDesc.Pants = 10023095999
			
	--	end
	--	local grey = Color3.new(0.5,0.5,0.5)
	--	local sk = Color3.new(1, 0.898039, 0.584314)
	--	humDesc.LeftArmColor = sk
	--	humDesc.RightArmColor = sk
	--	humDesc.TorsoColor = sk
	--	humDesc.LeftLegColor = sk
	--	humDesc.RightLegColor = sk
		
		
	--end
end)