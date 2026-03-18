extends Resource

class_name MatchConfig

@export_range(60.0, 600.0, 1.0, "or_greater") var match_duration_seconds: float = 240.0
@export_range(0.0, 10.0, 0.1, "or_greater") var start_delay_seconds: float = 1.0
@export_range(0, 10000, 1, "or_greater") var score_target: int = 150
@export_range(0, 4, 1, "or_greater") var player_slots: int = 1
@export_range(1, 12, 1, "or_greater") var ai_slots: int = 5
@export var arena_size: Vector2 = GameConstants.ARENA_DEFAULT_SIZE
@export var camera_padding: Vector2 = GameConstants.CAMERA_DEFAULT_PADDING
@export_range(0.25, 4.0, 0.05, "or_greater") var camera_min_zoom: float = 0.5
@export_range(0.25, 4.0, 0.05, "or_greater") var camera_max_zoom: float = 2.0
@export var auto_start_on_ready: bool = true
@export var use_fixed_seed: bool = true
@export var fixed_seed: int = 1001
@export var marble_scene: PackedScene
@export var marble_definitions: Array[MarbleDefinition] = []
@export var weapon_definitions: Array[WeaponDefinition] = []
@export var competitor_weapon_indices: PackedInt32Array = PackedInt32Array([2, 1, 3, 0, 2, 4])
@export_range(0.0, 10.0, 0.1, "or_greater") var collision_damage: float = 8.0
@export_range(0.0, 10.0, 0.1, "or_greater") var collision_pressure_bonus: float = 0.12
@export_range(0.0, 10.0, 0.1, "or_greater") var weapon_pressure_bonus_scale: float = 1.0
@export var use_respawn_elimination: bool = true
@export_range(0.1, 20.0, 0.1, "or_greater") var respawn_delay_seconds: float = 2.8
@export_range(0.0, 100.0, 0.5, "or_greater") var elimination_score_bonus: float = 8.0
@export var enable_debug_score_simulation: bool = false
@export_range(0.1, 5.0, 0.1, "or_greater") var debug_score_tick_seconds: float = 1.0
@export_range(1, 100, 1, "or_greater") var debug_score_award_min: int = 2
@export_range(1, 100, 1, "or_greater") var debug_score_award_max: int = 8
@export_range(4, 64, 1, "or_greater") var territory_columns: int = 16
@export_range(4, 64, 1, "or_greater") var territory_rows: int = 9
@export_range(0.1, 10.0, 0.1, "or_greater") var neutral_capture_seconds: float = 1.2
@export_range(0.1, 10.0, 0.1, "or_greater") var enemy_reclaim_seconds: float = 2.4
@export_range(0.0, 5.0, 0.05, "or_greater") var contested_capture_rate_multiplier: float = 0.35
@export_range(0.0, 5.0, 0.05, "or_greater") var protected_reclaim_rate_multiplier: float = 0.35
@export_range(0.0, 10.0, 0.1, "or_greater") var capture_protection_seconds: float = 1.6
@export_range(0.1, 5.0, 0.1, "or_greater") var territory_score_tick_seconds: float = 1.0
@export_range(0.0, 100.0, 0.5, "or_greater") var territory_score_weight: float = 12.0
@export_range(0.0, 100.0, 0.5, "or_greater") var territory_steal_bonus: float = 10.0
@export_range(0.0, 100.0, 0.5, "or_greater") var control_streak_bonus: float = 3.0
@export_range(0.0, 1.0, 0.05, "or_greater") var domination_threshold: float = 0.55
@export_range(8.0, 256.0, 1.0, "or_greater") var debug_agent_radius: float = 24.0
@export_range(16.0, 512.0, 1.0, "or_greater") var debug_agent_influence_radius: float = 115.0
@export_range(8.0, 512.0, 1.0, "or_greater") var debug_agent_speed_min: float = 60.0
@export_range(8.0, 512.0, 1.0, "or_greater") var debug_agent_speed_max: float = 140.0

func get_total_slots() -> int:
	return player_slots + ai_slots

func get_total_territory_cells() -> int:
	return territory_columns * territory_rows

func get_marble_scene() -> PackedScene:
	if marble_scene != null:
		return marble_scene
	return load(GameConstants.MARBLE_ACTOR_SCENE) as PackedScene

func get_marble_definition_for_index(index: int) -> MarbleDefinition:
	if marble_definitions.is_empty():
		return null
	var safe_index := posmod(index, marble_definitions.size())
	return marble_definitions[safe_index]

func get_weapon_definition_for_index(index: int) -> WeaponDefinition:
	if weapon_definitions.is_empty():
		return null
	if not competitor_weapon_indices.is_empty():
		var mapped_index := competitor_weapon_indices[posmod(index, competitor_weapon_indices.size())]
		if mapped_index >= 0 and mapped_index < weapon_definitions.size():
			return weapon_definitions[mapped_index]
	var safe_index := posmod(index, weapon_definitions.size())
	return weapon_definitions[safe_index]
