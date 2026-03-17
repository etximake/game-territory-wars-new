extends Node

const APP_ROOT_SCENE := "res://scenes/app/app_root.tscn"
const PROTOTYPE_WORLD_SCENE := "res://scenes/world/prototype_world.tscn"
const PROTOTYPE_MATCH_CONFIG := "res://resources/config/match_config_prototype.tres"
const PROTOTYPE_MATCH_DEBUG_OVERLAY_SCENE := "res://scenes/ui/prototype_match_debug_overlay.tscn"
const MARBLE_ACTOR_SCENE := "res://scenes/marble/marble_actor.tscn"

const GROUP_WORLD := &"world"
const GROUP_CAMERA := &"camera"
const GROUP_DEBUG := &"debug"
const GROUP_TERRITORY := &"territory"
const GROUP_TERRITORY_AGENT := &"territory_agent"
const GROUP_MARBLE := &"marble"

const ACTION_MATCH_START := &"match_start"
const ACTION_MATCH_RESTART := &"match_restart"

const ARENA_DEFAULT_SIZE := Vector2(1920.0, 1080.0)
const CAMERA_DEFAULT_PADDING := Vector2(160.0, 120.0)

enum PhysicsLayer {
	WORLD = 1,
	MARBLE = 2,
	PROJECTILE = 3,
	TERRITORY_SENSOR = 4,
	PICKUP = 5,
	CAMERA_BLOCKER = 6,
}

enum MatchFlowState {
	SETUP,
	STARTING,
	RUNNING,
	ENDED,
}

enum ScoreSource {
	TERRITORY_CONTROL,
	TERRITORY_STEAL,
	ELIMINATION,
	OBJECTIVE,
	CONTROL_STREAK,
	HIGHLIGHT_BONUS,
}

enum TerritoryCellState {
	NEUTRAL,
	OWNED,
	CONTESTED,
}

static func layer_bit(layer: int) -> int:
	return 1 << (layer - 1)

static func match_state_name(state: int) -> String:
	match state:
		MatchFlowState.SETUP:
			return "Setup"
		MatchFlowState.STARTING:
			return "Starting"
		MatchFlowState.RUNNING:
			return "Running"
		MatchFlowState.ENDED:
			return "Ended"
		_:
			return "Unknown"

static func score_source_name(source: int) -> String:
	match source:
		ScoreSource.TERRITORY_CONTROL:
			return "Territory"
		ScoreSource.TERRITORY_STEAL:
			return "Steal"
		ScoreSource.ELIMINATION:
			return "Elimination"
		ScoreSource.OBJECTIVE:
			return "Objective"
		ScoreSource.CONTROL_STREAK:
			return "Streak"
		ScoreSource.HIGHLIGHT_BONUS:
			return "Highlight"
		_:
			return "Unknown"

static func territory_state_name(state: int) -> String:
	match state:
		TerritoryCellState.NEUTRAL:
			return "Neutral"
		TerritoryCellState.OWNED:
			return "Owned"
		TerritoryCellState.CONTESTED:
			return "Contested"
		_:
			return "Unknown"
