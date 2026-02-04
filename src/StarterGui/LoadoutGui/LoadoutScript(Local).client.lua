local UserInputService = game:GetService("UserInputService")

local LoadoutFolder = game.ReplicatedStorage:WaitForChild("Loadout")
local LoadoutEvent = LoadoutFolder:WaitForChild("LoadoutEvent")
local TS = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Items = {}
local Outfit = nil

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Teams = game:GetService("Teams")
local Constants = require(ReplicatedStorage.Gameplay.Constants)

local openWindowName = "p"

local LoadoutGui = script.Parent
local LoadoutFrame = LoadoutGui.LoadoutFrame



--print("loaded loadoutscript")
UserInputService.MouseIconEnabled = true

if player.Team == Teams.Attack then
	Items = {"AR480", "P300-SD", "Flash Grenade", "Breaching Charge"}
	Outfit = "A1"
elseif player.Team == Teams.Defense then
	Items = {"SMG600-SD", "P150", "Fire Grenade", "Barbed Wire"}
	Outfit = "D1"
end

local CSLobbyModel : Model = Players:CreateHumanoidModelFromDescription(ReplicatedStorage.Loadout.Outfit[Outfit],Enum.HumanoidRigType.R6)
CSLobbyModel.Parent = Workspace.Lobby
CSLobbyModel:PivotTo(CFrame.new(Vector3.new(94, -23.5, -91),Vector3.new(92, -23.5, -91)))
print(CSLobbyModel)

--start with viewport clone
--local viewportCamera = Instance.new("Camera")
--LoadoutFrame.PreviewViewportFrame.CurrentCamera = viewportCamera
--viewportCamera.Parent = LoadoutFrame.PreviewViewportFrame

--local viewingClone : Model = Players:CreateHumanoidModelFromDescription(ReplicatedStorage.Loadout.Outfit[Outfit],Enum.HumanoidRigType.R6)
--viewingClone.Parent = Workspace
--viewingClone:PivotTo(CFrame.new(Vector3.new(0,-10,0),Vector3.new(0,0,0)))
--task.wait(0.25)
--viewingClone.Parent = LoadoutFrame.PreviewViewportFrame
--viewingClone:PivotTo(CFrame.new(Vector3.new(0,2,0),Vector3.new(0,2,1)))
--viewportCamera.CFrame = CFrame.new(Vector3.new(0, 0, 5), Vector3.new(0,0,0))

local function showSelected()
	for a,b in pairs(LoadoutFrame.WeaponsFrame:GetChildren()) do
		if b:isA("Frame") then
			for p,q in pairs(b:GetChildren()) do
				if q:IsA("TextButton") then
					q.BackgroundColor3 = Color3.fromRGB(150,150,150)
					for i,v in pairs({Items[1],Items[2],Items[3],Items[4],Outfit}) do
						if (q.Name == v) then
							q.BackgroundColor3 = player.TeamColor.Color
							break
						end
					end
				end
			end
		end
	end
end

local function complete()
	LoadoutGui.Enabled = false
	UserInputService.MouseIconEnabled = false
	LoadoutEvent:FireServer(Items,Outfit)
	CSLobbyModel:Destroy()
end

for i,v in pairs({LoadoutFolder.Primary, LoadoutFolder.Secondary, LoadoutFolder.Grenades, LoadoutFolder.Utility, LoadoutFolder.Outfit}) do
	for j, k in pairs(v:GetChildren()) do
		local teamAtt = k:GetAttribute("team")
		if teamAtt ~= "Both" and teamAtt ~= player.Team.Name then
			continue
		end



		--print(j,k)
		local newButton = LoadoutFrame.ExampleWeaponButton:Clone()
		newButton.Text = k.Name
		newButton.Name = k.Name

		if i == 1 then
			newButton.Parent = LoadoutFrame.WeaponsFrame.PrimaryFrame
		elseif i == 2 then
			newButton.Parent = LoadoutFrame.WeaponsFrame.SecondaryFrame
		elseif i == 3 then
			newButton.Parent = LoadoutFrame.WeaponsFrame.GrenadeFrame
		elseif i == 4 then
			newButton.Parent = LoadoutFrame.WeaponsFrame.UtilityFrame
		elseif i == 5 then
			newButton.Parent = LoadoutFrame.WeaponsFrame.OutfitFrame
		end

		newButton.Visible = true
		--print(newButton)

		--on click
		newButton.MouseButton1Click:Connect(function()

			newButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
			if i == 5 then
				Outfit = k.Name
			else
				Items[i] = k.Name
			end

			--set other button colors to grey
			showSelected()

			if k:isA("HumanoidDescription") then

				CSLobbyModel.Humanoid:ApplyDescription(ReplicatedStorage.Loadout.Outfit[Outfit]:Clone())
				print("switching to",Outfit)

			end



		end)
	end
end
showSelected()


Workspace:GetAttributeChangedSignal(Constants.PHASE_ATTRIBUTE):Connect(function()
	if (Workspace:GetAttribute(Constants.PHASE_ATTRIBUTE) == Constants.PHASE_EXECUTION) and (player.Team == Teams.Attack) then
		complete()
	elseif (Workspace:GetAttribute(Constants.PHASE_ATTRIBUTE) == Constants.PHASE_SETUP) and (player.Team == Teams.Defense) then
		complete()
	end
end)