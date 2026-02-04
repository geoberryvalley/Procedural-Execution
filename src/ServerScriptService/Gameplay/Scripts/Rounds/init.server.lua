local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")

local Constants = require(ReplicatedStorage.Gameplay.Constants)
local Scoring = require(script.Parent.Scoring)
local spawnCharacters = require(script.spawnCharacters)
local despawnCharacters = require(script.despawnCharacters)

local remotes = ReplicatedStorage.Gameplay.Remotes
local roundWinnerRemote = remotes.RoundWinner
local generateMapRemote = remotes:WaitForChild("GenerateMap")
local forceCameraRemote = remotes.ForceCamera

local mode = require(script.Parent.Modes.Defuse)

local random = Random.new()

local function startRoundLoopAsync()
	while true do
		task.wait(1)
		-- Reset scores
		Scoring.resetScores()

		local prepTimer = mode.prepTimer
		local setupTimer = mode.setupTimer
		local roundTimer = mode.roundTimer
		
		-- Start the mode, passing in a callback to be called if it finishes early
		local roundFinished = false
		mode.start(function()
			roundFinished = true
		end)
		
		
		generateMapRemote:Fire()
		
		-- Spawn characters
		Players.CharacterAutoLoads = true
		spawnCharacters()
		
		
		Workspace:SetAttribute(Constants.PHASE_ATTRIBUTE, Constants.PHASE_PREP)
		-- prep timer
		while prepTimer > 0 and not roundFinished do
			prepTimer -= 1
			Workspace:SetAttribute(Constants.TIMER_ATTRIBUTE, prepTimer)
			task.wait(1)
		end
		
		Workspace:SetAttribute(Constants.PHASE_ATTRIBUTE, Constants.PHASE_SETUP)
		-- setup timer
		while setupTimer > 0 and not roundFinished do
			setupTimer -= 1
			Workspace:SetAttribute(Constants.TIMER_ATTRIBUTE, setupTimer)
			task.wait(1)
		end
		
		Players.CharacterAutoLoads = false
		Workspace:SetAttribute(Constants.PHASE_ATTRIBUTE, Constants.PHASE_EXECUTION)
		-- round timer
		Workspace:SetAttribute(Constants.TIMER_ATTRIBUTE, roundTimer) 
		while Workspace:GetAttribute(Constants.TIMER_ATTRIBUTE) > 0 and not roundFinished and not Workspace:GetAttribute(Constants.IS_BOMB_DEFUSED_ATTRIBUTE) do
			roundTimer -= 1
			Workspace:SetAttribute(Constants.TIMER_ATTRIBUTE, roundTimer)
			task.wait(1)
		end
		
		-- End the mode
		mode.stop()

		-- Display winning team
		local winningTeam = nil
		if Workspace:GetAttribute(Constants.IS_BOMB_DEFUSED_ATTRIBUTE) == true then
			winningTeam = Teams.Attack
			Workspace:SetAttribute(Constants.IS_BOMB_DEFUSED_ATTRIBUTE, false)
		elseif Scoring.getTeamScore(Teams.Defense) <= 0 then
			winningTeam = Teams.Attack
		elseif Scoring.getTeamScore(Teams.Attack) <= 0 then
			winningTeam = Teams.Defense
		elseif roundTimer <= 0 then
			winningTeam = Teams.Defense
		else
			winningTeam = nil
			print("error bruh")
		end
		
		
		roundWinnerRemote:FireAllClients(winningTeam)
	
		-- Disable spawning
		--Players.CharacterAutoLoads = false
		Workspace:SetAttribute(Constants.PHASE_ATTRIBUTE, Constants.PHASE_INTERMISSION)
		despawnCharacters()

		-- Wait for intermission
		task.wait(Constants.INTERMISSION_TIME)
		
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") then
				if v.Team == Teams.Attack then
					v.Team = Teams.Defense
				elseif v.Team == Teams.Defense then
					v.Team = Teams.Attack
				end
			end
		end
		
		-- rebalance teams
		if #Teams.Attack:GetPlayers() > (#Teams.Defense:GetPlayers() + 1) then
			Teams.Attack:GetPlayers()[1].Team = Teams.Defense
		elseif #Teams.Defense:GetPlayers() > (#Teams.Attack:GetPlayers() + 1) then
			Teams.Defense:GetPlayers()[1].Team = Teams.Attack
		end
		
	end
end

task.spawn(startRoundLoopAsync)
