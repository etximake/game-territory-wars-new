extends Node2D

class_name PrototypeWorld

@export var match_config: MatchConfig

@onready var arena: PrototypeArena = $Arena
@onready var territory_controller: TerritoryController = $TerritoryController
@onready var match_controller: MatchController = $MatchController
@onready var prototype_camera: PrototypeCamera = $PrototypeCamera
@onready var spawn_root: Node2D = $SpawnRoot
@onready var debug_root: Node2D = $DebugRoot
@onready var debug_overlay: PrototypeMatchDebugOverlay = $PrototypeMatchDebugOverlay/Control

var _marble_actors: Array[MarbleActor] = []

func _ready() -> void:
	add_to_group(GameConstants.GROUP_WORLD)
	_connect_match_signals()
	_connect_territory_signals()
	_apply_match_config()

func initialize(config: MatchConfig) -> void:
	match_config = config
	if is_node_ready():
		_apply_match_config()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(GameConstants.ACTION_MATCH_START):
		if _ensure_match_config_ready():
			match_controller.start_match()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(GameConstants.ACTION_MATCH_RESTART):
		if _ensure_match_config_ready():
			match_controller.restart_match()
			get_viewport().set_input_as_handled()

func _apply_match_config() -> void:
	if not _ensure_match_config_ready():
		return

	arena.arena_size = match_config.arena_size
	arena.rebuild()

	prototype_camera.padding = match_config.camera_padding
	prototype_camera.min_zoom_factor = match_config.camera_min_zoom
	prototype_camera.max_zoom_factor = match_config.camera_max_zoom
	prototype_camera.frame_rect(arena.get_bounds())

	debug_overlay.show_waiting_state()
	territory_controller.initialize(match_config, arena.get_bounds())
	match_controller.initialize(match_config)
	var roster_summary := match_controller.get_roster_summary()
	if territory_controller.roster.is_empty():
		territory_controller.set_roster(roster_summary)
	_sync_marble_actors(roster_summary)
	territory_controller.set_marble_actors(_marble_actors)
	_sync_marble_state_with_match()
	if not match_config.auto_start_on_ready:
		debug_overlay.update_scoreboard(-1, match_controller.get_leaderboard_summary())

func _ensure_match_config_ready() -> bool:
	if match_config != null:
		return true

	var loaded_config := load(GameConstants.PROTOTYPE_MATCH_CONFIG)
	if loaded_config is MatchConfig:
		match_config = loaded_config
		return true

	push_error("PrototypeWorld could not resolve a valid MatchConfig resource.")
	return false

func _connect_match_signals() -> void:
	if match_controller.match_state_changed.is_connected(_on_match_state_changed):
		return

	match_controller.match_state_changed.connect(_on_match_state_changed)
	match_controller.timer_updated.connect(_on_timer_updated)
	match_controller.score_changed.connect(_on_score_changed)
	match_controller.match_started.connect(_on_match_started)
	match_controller.match_ended.connect(_on_match_ended)

func _connect_territory_signals() -> void:
	if territory_controller.score_awarded.is_connected(_on_territory_score_awarded):
		return

	territory_controller.score_awarded.connect(_on_territory_score_awarded)
	territory_controller.debug_state_changed.connect(_on_territory_debug_state_changed)

func _on_match_state_changed(new_state: int) -> void:
	debug_overlay.update_match_state(new_state)
	if new_state == GameConstants.MatchFlowState.SETUP:
		territory_controller.stop_match()
		territory_controller.reset_grid()
		_stop_marble_actors()
	elif new_state == GameConstants.MatchFlowState.STARTING:
		var roster_summary := match_controller.get_roster_summary()
		territory_controller.set_roster(roster_summary)
		_sync_marble_actors(roster_summary)
		_reset_marble_actors_for_match(match_controller.active_seed)
	elif new_state == GameConstants.MatchFlowState.RUNNING:
		territory_controller.set_roster(match_controller.get_roster_summary())
		territory_controller.set_marble_actors(_marble_actors)
		_start_marble_actors(match_controller.active_seed)
		territory_controller.start_match(match_controller.active_seed)
	elif new_state == GameConstants.MatchFlowState.ENDED:
		territory_controller.stop_match()
		_stop_marble_actors()

func _on_timer_updated(time_remaining_seconds: float, elapsed_seconds: float) -> void:
	debug_overlay.update_timer(time_remaining_seconds, elapsed_seconds)

func _on_score_changed(leader_id: int, leaderboard: Array[Dictionary]) -> void:
	debug_overlay.update_scoreboard(leader_id, leaderboard)

func _on_match_started(match_seed: int) -> void:
	debug_overlay.update_seed(match_seed)

func _on_match_ended(result: MatchResult) -> void:
	debug_overlay.show_match_result(result)

func _on_territory_score_awarded(competitor_id: int, source: int, amount: float) -> void:
	match_controller.award_score(competitor_id, source, amount)

func _on_territory_debug_state_changed(lines: PackedStringArray) -> void:
	debug_overlay.update_territory_summary(lines)

func _sync_marble_actors(roster_summary: Array[Dictionary]) -> void:
	_clear_marble_actors()
	var marble_scene := match_config.get_marble_scene()
	if marble_scene == null:
		push_error("PrototypeWorld could not resolve a marble scene for Phase D.")
		return

	for entry in roster_summary:
		var marble_instance := marble_scene.instantiate()
		if not (marble_instance is MarbleActor):
			push_error("Marble scene must instantiate MarbleActor.")
			marble_instance.queue_free()
			continue
		var marble_actor := marble_instance as MarbleActor
		spawn_root.add_child(marble_actor)
		var competitor_id := int(entry.get("competitor_id", 0))
		marble_actor.configure(entry, arena.get_bounds(), match_config, match_controller.active_seed + competitor_id + 31)
		_marble_actors.append(marble_actor)

func _clear_marble_actors() -> void:
	for marble_actor in _marble_actors:
		if is_instance_valid(marble_actor):
			marble_actor.queue_free()
	_marble_actors.clear()

func _sync_marble_state_with_match() -> void:
	if match_controller.state == GameConstants.MatchFlowState.STARTING:
		_reset_marble_actors_for_match(match_controller.active_seed)
	elif match_controller.state == GameConstants.MatchFlowState.RUNNING:
		_start_marble_actors(match_controller.active_seed)
		territory_controller.start_match(match_controller.active_seed)
	else:
		_stop_marble_actors()

func _reset_marble_actors_for_match(match_seed: int) -> void:
	for marble_actor in _marble_actors:
		if not is_instance_valid(marble_actor):
			continue
		marble_actor.stop_match()
		marble_actor.reset_for_match(match_seed + marble_actor.competitor_id + 17, match_config)
	territory_controller.set_marble_actors(_marble_actors)

func _start_marble_actors(match_seed: int) -> void:
	for marble_actor in _marble_actors:
		if not is_instance_valid(marble_actor):
			continue
		marble_actor.reset_for_match(match_seed + marble_actor.competitor_id + 17, match_config)
		marble_actor.start_match()
	territory_controller.set_marble_actors(_marble_actors)

func _stop_marble_actors() -> void:
	for marble_actor in _marble_actors:
		if is_instance_valid(marble_actor):
			marble_actor.stop_match()
