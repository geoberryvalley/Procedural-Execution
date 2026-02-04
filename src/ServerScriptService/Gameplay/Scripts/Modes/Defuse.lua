local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Scoring = require(script.Parent.Parent.Scoring)
local disconnectAndClear = require(ReplicatedStorage.Utility.disconnectAndClear)

local blasterEvents = ServerScriptService.Blaster.Events
local eliminatedEvent = blasterEvents.Eliminated

local TEAM_SCORE_LIMIT = 0

local connections = {}

local Mode = {
	roundTimer = 60 * 1.5,
	setupTimer = 60 * 0.25,
	prepTimer = 60 * 0.25,
}

function Mode.start(finish: () -> ()) --add bomb that can be defused
	--how scoring should work: alive = 1 pt, dead = 0 pts, bomb defuse = insta win using event
	table.insert(
		connections,
		eliminatedEvent.Event:Connect(function(player: Player, eliminatedHumanoid: Humanoid)
			local eliminatedCharacter = eliminatedHumanoid.Parent
			local eliminatedPlayer = Players:GetPlayerFromCharacter(eliminatedCharacter)
			Scoring.incrementScore(eliminatedPlayer, -1)
			
			-- Finish early when a team reaches the scoring limit
			-- CHANGE THIS BECAUSE IF THE LAST PERSON ALIVE DQS THE GAME WILL NOT END (add connection to updateTeamScore or sumn)
			if eliminatedPlayer.Team then
				-- Since we are using deferred events, the team score will not get updated until the end of this frame.
				-- We'll defer the check so that we get an accurate number.
				task.defer(function()
					local teamScore = Scoring.getTeamScore(eliminatedPlayer.Team)
					if teamScore <= TEAM_SCORE_LIMIT then
						finish()
					end
				end)
			end
		end)
	)
	
end

function Mode.stop()
	disconnectAndClear(connections)
end

return Mode
