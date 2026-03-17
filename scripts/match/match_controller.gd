extends Node

class_name MatchController

signal match_state_changed(new_state: int)
signal timer_updated(time_remaining_seconds: float, elapsed_seconds: float)
signal score_changed(leader_id: int, leaderboard: Array[Dictionary])
signal match_started(match_seed: int)
signal match_ended(result: MatchResult)

const COMPETITOR_COLORS = [
	Color("ff6b6b"),
	Color("4ecdc4"),
	Color("ffe66d"),
	Color("6c8cff"),
	Color("c77dff"),
	Color("7bd389"),
	Color("ff9f1c"),
]

@export var match_config: MatchConfig

var state: int = GameConstants.MatchFlowState.SETUP
var active_seed: int = 0
var current_run_index: int = 0
var elapsed_seconds: float = 0.0
var time_remaining_seconds: float = 0.0
var start_delay_remaining_seconds: float = 0.0
var competitors: Array[MatchCompetitorState] = []
var latest_result: MatchResult

var _rng := RandomNumberGenerator.new()
var _next_dynamic_seed: int = 1
var _debug_score_tick_accumulator: float = 0.0

func _ready() -> void:
	set_process(false)

func initialize(config: MatchConfig) -> void:
	match_config = config
	_prepare_roster()
	reset_match_state(false)
	if match_config.auto_start_on_ready:
		start_match()

func start_match() -> void:
	if match_config == null:
		push_error("MatchController requires match_config before start_match.")
		return
	if state == GameConstants.MatchFlowState.RUNNING or state == GameConstants.MatchFlowState.STARTING:
		return

	reset_match_state(false)
	active_seed = _resolve_seed()
	_rng.seed = active_seed
	current_run_index += 1
	start_delay_remaining_seconds = match_config.start_delay_seconds
	if start_delay_remaining_seconds > 0.0:
		state = GameConstants.MatchFlowState.STARTING
	else:
		state = GameConstants.MatchFlowState.RUNNING
	set_process(true)
	match_state_changed.emit(state)
	match_started.emit(active_seed)
	timer_updated.emit(time_remaining_seconds, elapsed_seconds)
	score_changed.emit(_get_leader_id(), get_leaderboard_summary())

func restart_match() -> void:
	start_match()

func reset_match_state(emit_signal: bool = true) -> void:
	elapsed_seconds = 0.0
	if match_config == null:
		time_remaining_seconds = 0.0
	else:
		time_remaining_seconds = match_config.match_duration_seconds
	start_delay_remaining_seconds = 0.0
	_debug_score_tick_accumulator = 0.0
	latest_result = null
	for competitor in competitors:
		competitor.reset()
	state = GameConstants.MatchFlowState.SETUP
	set_process(false)
	if emit_signal:
		match_state_changed.emit(state)
		timer_updated.emit(time_remaining_seconds, elapsed_seconds)
		score_changed.emit(_get_leader_id(), get_leaderboard_summary())

func award_score(competitor_id: int, source: int, amount: float) -> void:
	var competitor := _find_competitor(competitor_id)
	if competitor == null:
		push_warning("Unknown competitor id %s in award_score." % competitor_id)
		return

	competitor.add_score(source, amount)
	score_changed.emit(_get_leader_id(), get_leaderboard_summary())
	_check_end_conditions()

func get_leaderboard_summary() -> Array[Dictionary]:
	var leaderboard: Array[Dictionary] = []
	for competitor in competitors:
		leaderboard.append(competitor.to_summary())
	leaderboard.sort_custom(_sort_competitor_summary)
	return leaderboard

func get_roster_summary() -> Array[Dictionary]:
	var roster_summary: Array[Dictionary] = []
	for competitor in competitors:
		roster_summary.append(competitor.to_summary())
	return roster_summary

func get_time_remaining_seconds() -> float:
	return time_remaining_seconds

func get_elapsed_seconds() -> float:
	return elapsed_seconds

func _process(delta: float) -> void:
	if match_config == null:
		return

	match state:
		GameConstants.MatchFlowState.STARTING:
			_update_starting_state(delta)
		GameConstants.MatchFlowState.RUNNING:
			_update_running_state(delta)

func _update_starting_state(delta: float) -> void:
	start_delay_remaining_seconds = maxf(start_delay_remaining_seconds - delta, 0.0)
	if start_delay_remaining_seconds <= 0.0:
		state = GameConstants.MatchFlowState.RUNNING
		match_state_changed.emit(state)
		timer_updated.emit(time_remaining_seconds, elapsed_seconds)

func _update_running_state(delta: float) -> void:
	elapsed_seconds += delta
	time_remaining_seconds = maxf(match_config.match_duration_seconds - elapsed_seconds, 0.0)
	timer_updated.emit(time_remaining_seconds, elapsed_seconds)

	if match_config.enable_debug_score_simulation:
		_run_debug_score_simulation(delta)

	if time_remaining_seconds <= 0.0:
		_end_match("time_limit")

func _run_debug_score_simulation(delta: float) -> void:
	_debug_score_tick_accumulator += delta
	while _debug_score_tick_accumulator >= match_config.debug_score_tick_seconds:
		_debug_score_tick_accumulator -= match_config.debug_score_tick_seconds
		if competitors.is_empty():
			return
		var winner_index := _rng.randi_range(0, competitors.size() - 1)
		var points := _rng.randi_range(match_config.debug_score_award_min, match_config.debug_score_award_max)
		award_score(competitors[winner_index].competitor_id, GameConstants.ScoreSource.TERRITORY_CONTROL, points)

func _check_end_conditions() -> void:
	if state != GameConstants.MatchFlowState.RUNNING:
		return
	if match_config.score_target <= 0:
		return

	var leader := _get_leader()
	if leader != null and leader.total_score >= match_config.score_target:
		_end_match("score_target")

func _end_match(reason: String) -> void:
	if state == GameConstants.MatchFlowState.ENDED:
		return

	state = GameConstants.MatchFlowState.ENDED
	set_process(false)
	match_state_changed.emit(state)

	var leader := _get_leader()
	latest_result = MatchResult.new()
	latest_result.final_state = state
	latest_result.reason = reason
	latest_result.reached_score_target = reason == "score_target"
	latest_result.time_elapsed_seconds = elapsed_seconds
	latest_result.match_seed = active_seed
	latest_result.score_summaries = get_leaderboard_summary()
	if leader != null:
		latest_result.winning_competitor_id = leader.competitor_id
		latest_result.winning_display_name = leader.display_name
	match_ended.emit(latest_result)

func _prepare_roster() -> void:
	competitors.clear()
	if match_config == null:
		return

	for player_index in range(match_config.player_slots):
		competitors.append(_create_competitor(player_index, true))
	for ai_offset in range(match_config.ai_slots):
		competitors.append(_create_competitor(match_config.player_slots + ai_offset, false))

	_next_dynamic_seed = maxi(1, match_config.fixed_seed)

func _create_competitor(index: int, is_player: bool) -> MatchCompetitorState:
	var display_name := ""
	if is_player:
		display_name = "Player %d" % (index + 1)
	else:
		display_name = "AI %d" % (index + 1 - match_config.player_slots)
	var color: Color = COMPETITOR_COLORS[index % COMPETITOR_COLORS.size()]
	var marble_definition := match_config.get_marble_definition_for_index(index)
	return MatchCompetitorState.new(index, display_name, is_player, color, marble_definition)

func _resolve_seed() -> int:
	if match_config.use_fixed_seed:
		return match_config.fixed_seed
	var resolved_seed := _next_dynamic_seed
	_next_dynamic_seed += 1
	return resolved_seed

func _find_competitor(competitor_id: int) -> MatchCompetitorState:
	for competitor in competitors:
		if competitor.competitor_id == competitor_id:
			return competitor
	return null

func _get_leader() -> MatchCompetitorState:
	if competitors.is_empty():
		return null
	var sorted_competitors := competitors.duplicate()
	sorted_competitors.sort_custom(_sort_competitor_state)
	return sorted_competitors[0]

func _get_leader_id() -> int:
	var leader := _get_leader()
	if leader == null:
		return -1
	return leader.competitor_id

func _sort_competitor_state(a: MatchCompetitorState, b: MatchCompetitorState) -> bool:
	if not is_equal_approx(a.total_score, b.total_score):
		return a.total_score > b.total_score
	return a.competitor_id < b.competitor_id

func _sort_competitor_summary(a: Dictionary, b: Dictionary) -> bool:
	var a_score := float(a.get("total_score", 0.0))
	var b_score := float(b.get("total_score", 0.0))
	if not is_equal_approx(a_score, b_score):
		return a_score > b_score
	return int(a.get("competitor_id", 0)) < int(b.get("competitor_id", 0))
