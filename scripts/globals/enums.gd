class_name Enums

enum GameState {
	ON_START,
	IN_GAME,
	PAUSED,
}

enum LevelState {
	WAIT_START, # Start sequence before u gain control of player
	RACING,
	DYING, # Fell off track and respawning
	END,
}

enum CheatInput {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}
