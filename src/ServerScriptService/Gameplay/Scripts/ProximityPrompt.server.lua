local ProximityPromptService = game:GetService("ProximityPromptService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Gameplay.Constants)

local announcementSound = Workspace.GlobalAnnouncer

-- Detect when prompt is triggered
local function onPromptTriggered(promptObject : ProximityPrompt, player : Player)
	print(promptObject,player,"TRIGGERED PROMPT!!!!")
	if promptObject.Name == "OpenGreenDoor" then --green doors
		local door = promptObject.Parent
		local sound = door:FindFirstChildWhichIsA("Sound")
		door.CanCollide = not door.CanCollide
		door.CanTouch = not door.CanTouch
		door.CanQuery = not door.CanQuery
		door.Transparency = door.Transparency == 1 and 0 or 1
		if door.Transparency == 1 then
			sound.SoundId = "rbxassetid://157167203"
		else
			sound.SoundId = "rbxassetid://157167205"
		end
		sound:Play()
	elseif promptObject.Name == "OpenRedDoor" then --red doors
		if player.character:FindFirstChildOfClass("Tool").Name == "Breaching Charge" then
			local door = promptObject.Parent
			local sound = door:FindFirstChildWhichIsA("Sound")
			local explosion = Instance.new("Explosion")
			explosion.BlastPressure = 0
			explosion.BlastRadius = 0
			explosion.DestroyJointRadiusPercent = 0
			explosion.Parent = workspace.Placeables
			explosion.Position = door.Position
			--destroy the prompt and make the door look invisible so the sound still plays
			promptObject:Destroy()
			door.CanCollide = false
			door.CanTouch = false
			door.CanQuery = false
			door.Transparency = 1
			player.character:FindFirstChildOfClass("Tool"):Destroy()
			sound.SoundId = "rbxassetid://156283117"
			sound:Play()
		end
		
	elseif promptObject == workspace.Bomb.Defuse and player.Team == Teams.Attack then -- bomb
		Workspace:SetAttribute(Constants.IS_BOMB_DEFUSED_ATTRIBUTE, true)
		announcementSound.SoundId = "rbxassetid://9117341652"
		announcementSound:Play()
	end
end

-- Detect when prompt hold begins
local function onPromptHoldBegan(promptObject, player)
	if promptObject.Name == "OpenRedDoor" and player.Team == Teams.Attack then --red door FBI OPEN UP (lol)
		local sound = promptObject.Parent:FindFirstChildWhichIsA("Sound")
		if player.character:FindFirstChildOfClass("Tool").Name == "Breaching Charge" and not sound.Playing then
			sound.SoundId = "rbxassetid://3302969109"
			sound:Play()
		end
	elseif promptObject == workspace.Bomb.Defuse and player.Team == Teams.Attack and not announcementSound.IsPlaying then -- bomb
		announcementSound.SoundId = "rbxassetid://74350498996871"
		announcementSound:Play()
	end
end

-- Detect when prompt hold ends
local function onPromptHoldEnded(promptObject, player)
	
end

-- Connect prompt events to handling functions
ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)
ProximityPromptService.PromptButtonHoldBegan:Connect(onPromptHoldBegan)
ProximityPromptService.PromptButtonHoldEnded:Connect(onPromptHoldEnded)