local Constants = {
	TIMER_ATTRIBUTE = "timer",
	PHASE_ATTRIBUTE = "phase",
	PHASE_PREP = "preparation",
	PHASE_SETUP = "setup",
	PHASE_EXECUTION = "execution",
	PHASE_INTERMISSION = "intermission",
	TEAM_SCORE_ATTRIBUTE = "score",
	INTERMISSION_TIME = 10,
	IS_BOMB_DEFUSED_ATTRIBUTE = "isBombDefused",

	-- Pixel size under which a screen is considered 'small'. This is the same threshold used by the default touch UI.
	UI_SMALL_SCREEN_THRESHOLD = 500,
	-- Amount to scale the UI when on a small screen
	UI_SMALL_SCREEN_SCALE = 0.8,
}

return Constants
