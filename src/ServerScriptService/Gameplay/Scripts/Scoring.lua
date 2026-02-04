--!nocheck

--[[
	Rather than setting up a fully custom scoring system, we'll use the built in 'leaderstats' system
	which integrates with the default leaderboard to track player scores.
	https://create.roblox.com/docs/players/leaderboards
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Gameplay.Constants)
local safePlayerAdded = require(ReplicatedStorage.Utility.safePlayerAdded)

local Scoring = {}

local function updateTeamScore(team: Team)
	-- Since the default leaderstats system doesn't have an easy way to check team stats, we'll manually
	-- keep track of team scores with an attribute on each team.
	local score = 0
	local players = team:GetPlayers()
	for _, player in players do
		score += Scoring.getPlayerScore(player)
	end
	team:SetAttribute(Constants.TEAM_SCORE_ATTRIBUTE, score)
	--very cursed code to force check to see if last player leaves
	if team:GetAttribute(Constants.TEAM_SCORE_ATTRIBUTE) == 0 then
		Workspace:SetAttribute(Constants.TIMER_ATTRIBUTE, -10)
	end
end

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local score = Instance.new("IntValue")
	score.Name = "Score"
	score.Value = 0
	score.Parent = leaderstats
	
	if workspace:GetAttribute(Constants.PHASE_ATTRIBUTE) == Constants.PHASE_PREP then --if they are in the prep phase (spawned in, then they get a life)
		score.Value = 1
	end

	-- Each time the player's score changes, update the total score for the team they're on
	score.Changed:Connect(function()
		if player.Team then
			updateTeamScore(player.Team)
		end
	end)
end

local function onPlayerRemoving(player: Player)
	-- When a player leaves, make sure to update their team's score
	print("leaving: ",player)
	--since for some reason player.Team returns nil, we are going to brute force check both teams to update the score
	updateTeamScore(Teams.Attack)
	updateTeamScore(Teams.Defense)
end

function Scoring.resetScores()
	for _, player in Players:GetPlayers() do
		player.leaderstats.Score.Value = 1 --set to 1 because they are alive
	end
	updateTeamScore(Teams.Attack)
	updateTeamScore(Teams.Defense)
end

function Scoring.incrementScore(player: Player, amount: number)
	local score = player.leaderstats.Score
	score.Value += amount
end

function Scoring.getPlayerScore(player: Player): number
	return player.leaderstats.Score.Value
end

function Scoring.getTeamScore(team: Team): number
	return team:GetAttribute(Constants.TEAM_SCORE_ATTRIBUTE) or 0
end

safePlayerAdded(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

return Scoring
