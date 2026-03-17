extends Node2D

class_name TerritoryController

signal ownership_changed(owner_percentages: Dictionary, contested_cells: int)
signal score_awarded(competitor_id: int, source: int, amount: float)
signal debug_state_changed(summary_lines: PackedStringArray)

@export var match_config: MatchConfig

var arena_bounds: Rect2 = Rect2()
var cell_size: Vector2 = Vector2.ZERO
var cells: Array[TerritoryCell] = []
var roster: Array[Dictionary] = []
var marble_actors: Array[MarbleActor] = []
var active_match_seed: int = 0
var is_match_running: bool = false
var owner_percentages: Dictionary = {}
var contested_cell_count: int = 0

var _score_tick_accumulator: float = 0.0
var _control_streak_owner_id: int = -1
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group(GameConstants.GROUP_TERRITORY)
	set_process(false)

func initialize(config: MatchConfig, bounds: Rect2) -> void:
	match_config = config
	arena_bounds = bounds
	cell_size = Vector2(
		bounds.size.x / float(match_config.territory_columns),
		bounds.size.y / float(match_config.territory_rows)
	)
	_build_cells()
	queue_redraw()
	_emit_debug_summary()

func set_roster(new_roster: Array[Dictionary]) -> void:
	roster = []
	for entry in new_roster:
		roster.append(entry.duplicate(true))
	_reset_ownership_percentages()
	queue_redraw()
	_emit_debug_summary()

func set_marble_actors(new_marble_actors: Array[MarbleActor]) -> void:
	marble_actors.clear()
	for marble_actor in new_marble_actors:
		if is_instance_valid(marble_actor):
			marble_actors.append(marble_actor)
	_emit_debug_summary()

func start_match(match_seed: int) -> void:
	active_match_seed = match_seed
	_rng.seed = active_match_seed
	reset_grid()
	is_match_running = true
	_score_tick_accumulator = 0.0
	_control_streak_owner_id = -1
	set_process(true)
	queue_redraw()
	_emit_debug_summary()

func stop_match() -> void:
	is_match_running = false
	set_process(false)
	queue_redraw()
	_emit_debug_summary()

func reset_grid() -> void:
	for cell in cells:
		cell.reset()
	_reset_ownership_percentages()
	contested_cell_count = 0
	ownership_changed.emit(owner_percentages.duplicate(true), contested_cell_count)
	queue_redraw()

func get_owner_percentages() -> Dictionary:
	return owner_percentages.duplicate(true)

func get_contested_cell_count() -> int:
	return contested_cell_count

func _process(delta: float) -> void:
	if not is_match_running:
		return

	_update_cells(delta)
	_update_score_tick(delta)
	queue_redraw()

func _draw() -> void:
	if cells.is_empty():
		return

	for cell in cells:
		var rect := _get_cell_rect(cell)
		draw_rect(rect, _get_cell_fill_color(cell), true)
		draw_rect(rect, Color(0.06, 0.08, 0.1, 0.55), false, 1.0)
		if cell.is_protected() and cell.owner_id >= 0:
			draw_rect(rect.grow(-3.0), Color.WHITE, false, 2.0)

func _build_cells() -> void:
	cells.clear()
	var total_cells := match_config.territory_columns * match_config.territory_rows
	cells.resize(total_cells)
	for row in range(match_config.territory_rows):
		for column in range(match_config.territory_columns):
			var cell := TerritoryCell.new()
			cell.cell_index = row * match_config.territory_columns + column
			cell.grid_position = Vector2i(column, row)
			cells[cell.cell_index] = cell

func _update_cells(delta: float) -> void:
	var owned_counts: Dictionary = {}
	var contested_total := 0
	for entry in roster:
		owned_counts[int(entry.get("competitor_id", -1))] = 0

	for cell in cells:
		if cell.protection_remaining_seconds > 0.0:
			cell.protection_remaining_seconds = maxf(cell.protection_remaining_seconds - delta, 0.0)

		var influences := _collect_influences_for_cell(cell)
		_resolve_cell_state(cell, influences, delta)
		if cell.state == GameConstants.TerritoryCellState.CONTESTED:
			contested_total += 1
		elif cell.owner_id >= 0:
			owned_counts[cell.owner_id] = int(owned_counts.get(cell.owner_id, 0)) + 1

	contested_cell_count = contested_total
	owner_percentages.clear()
	var total_cells := float(cells.size())
	for competitor_id in owned_counts.keys():
		owner_percentages[competitor_id] = float(owned_counts[competitor_id]) / total_cells

	ownership_changed.emit(owner_percentages.duplicate(true), contested_cell_count)
	_emit_debug_summary()

func _collect_influences_for_cell(cell: TerritoryCell) -> Dictionary:
	var result := {}
	var cell_center := _get_cell_rect(cell).get_center()
	for marble_actor in marble_actors:
		if not is_instance_valid(marble_actor):
			continue
		var influence := marble_actor.get_influence_at(cell_center)
		if influence <= 0.0:
			continue
		var competitor_id := marble_actor.competitor_id
		var entry: Dictionary = result.get(competitor_id, {
			"influence": 0.0,
			"neutral_capture_rate": 1.0,
			"enemy_reclaim_rate": 1.0,
		})
		entry["influence"] = float(entry.get("influence", 0.0)) + influence
		entry["neutral_capture_rate"] = maxf(float(entry.get("neutral_capture_rate", 1.0)), marble_actor.get_neutral_capture_rate())
		entry["enemy_reclaim_rate"] = maxf(float(entry.get("enemy_reclaim_rate", 1.0)), marble_actor.get_enemy_reclaim_rate())
		result[competitor_id] = entry
	return result

func _resolve_cell_state(cell: TerritoryCell, influences: Dictionary, delta: float) -> void:
	if influences.is_empty():
		if cell.owner_id < 0:
			cell.state = GameConstants.TerritoryCellState.NEUTRAL
		else:
			cell.state = GameConstants.TerritoryCellState.OWNED
		cell.contested_by = PackedInt32Array()
		cell.capture_progress = maxf(cell.capture_progress - delta * 0.5, 0.0)
		if cell.capture_progress <= 0.0:
			cell.capture_target_id = -1
		return

	var competitor_ids: Array = influences.keys()
	competitor_ids.sort()
	var contested_ids := PackedInt32Array()
	for competitor_id_variant in competitor_ids:
		contested_ids.append(int(competitor_id_variant))
	cell.contested_by = contested_ids

	var top_competitor_id := int(competitor_ids[0])
	var top_metrics: Dictionary = influences[top_competitor_id]
	var top_influence := float(top_metrics.get("influence", 0.0))
	var second_influence := -1.0
	for competitor_id_variant in competitor_ids:
		var competitor_id := int(competitor_id_variant)
		var metrics: Dictionary = influences[competitor_id]
		var influence := float(metrics.get("influence", 0.0))
		if influence > top_influence:
			second_influence = top_influence
			top_influence = influence
			top_competitor_id = competitor_id
			top_metrics = metrics
		elif influence > second_influence and competitor_id != top_competitor_id:
			second_influence = influence

	var is_contested := competitor_ids.size() > 1
	var progress_multiplier := 1.0
	if is_contested:
		cell.state = GameConstants.TerritoryCellState.CONTESTED
		progress_multiplier = match_config.contested_capture_rate_multiplier
		if is_equal_approx(top_influence, second_influence):
			cell.capture_progress = maxf(cell.capture_progress - delta * 0.75, 0.0)
			if cell.capture_progress <= 0.0:
				cell.capture_target_id = -1
			return
	else:
		if cell.owner_id < 0:
			cell.state = GameConstants.TerritoryCellState.NEUTRAL
		else:
			cell.state = GameConstants.TerritoryCellState.OWNED

	var capture_duration := match_config.neutral_capture_seconds
	var capture_rate := maxf(float(top_metrics.get("neutral_capture_rate", 1.0)), 0.1)
	if cell.owner_id >= 0 and cell.owner_id != top_competitor_id:
		capture_duration = match_config.enemy_reclaim_seconds
		capture_rate = maxf(float(top_metrics.get("enemy_reclaim_rate", 1.0)), 0.1)
		if cell.is_protected():
			progress_multiplier *= match_config.protected_reclaim_rate_multiplier
	capture_duration /= capture_rate

	if cell.owner_id == top_competitor_id:
		cell.state = GameConstants.TerritoryCellState.OWNED
		cell.capture_progress = 0.0
		cell.capture_target_id = -1
		return

	if cell.capture_target_id != top_competitor_id:
		cell.capture_target_id = top_competitor_id
		cell.capture_progress = 0.0

	cell.capture_progress += (delta / capture_duration) * progress_multiplier
	if cell.capture_progress < 1.0:
		return

	var previous_owner_id := cell.owner_id
	cell.owner_id = top_competitor_id
	cell.state = GameConstants.TerritoryCellState.OWNED
	cell.capture_progress = 0.0
	cell.capture_target_id = -1
	cell.protection_remaining_seconds = match_config.capture_protection_seconds
	if previous_owner_id >= 0 and previous_owner_id != top_competitor_id:
		score_awarded.emit(top_competitor_id, GameConstants.ScoreSource.TERRITORY_STEAL, match_config.territory_steal_bonus)

func _update_score_tick(delta: float) -> void:
	_score_tick_accumulator += delta
	if _score_tick_accumulator < match_config.territory_score_tick_seconds:
		return

	while _score_tick_accumulator >= match_config.territory_score_tick_seconds:
		_score_tick_accumulator -= match_config.territory_score_tick_seconds
		var lead_owner_id := _find_leading_owner_id()
		for competitor_id_variant in owner_percentages.keys():
			var competitor_id := int(competitor_id_variant)
			var owned_percent := float(owner_percentages[competitor_id])
			if owned_percent <= 0.0:
				continue
			var control_score := owned_percent * match_config.territory_score_weight
			score_awarded.emit(competitor_id, GameConstants.ScoreSource.TERRITORY_CONTROL, control_score)
		if lead_owner_id >= 0 and float(owner_percentages.get(lead_owner_id, 0.0)) >= match_config.domination_threshold:
			if _control_streak_owner_id == lead_owner_id:
				score_awarded.emit(lead_owner_id, GameConstants.ScoreSource.CONTROL_STREAK, match_config.control_streak_bonus)
			else:
				_control_streak_owner_id = lead_owner_id
		else:
			_control_streak_owner_id = -1

func _find_leading_owner_id() -> int:
	var best_id := -1
	var best_percent := -1.0
	for competitor_id_variant in owner_percentages.keys():
		var competitor_id := int(competitor_id_variant)
		var owned_percent := float(owner_percentages[competitor_id])
		if owned_percent > best_percent:
			best_id = competitor_id
			best_percent = owned_percent
	return best_id

func _get_cell_rect(cell: TerritoryCell) -> Rect2:
	var cell_position := arena_bounds.position + Vector2(cell.grid_position.x, cell.grid_position.y) * cell_size
	return Rect2(cell_position, cell_size)

func _get_cell_fill_color(cell: TerritoryCell) -> Color:
	if cell.state == GameConstants.TerritoryCellState.CONTESTED:
		return Color(0.94, 0.77, 0.34, 0.9)
	if cell.owner_id < 0:
		return Color(0.16, 0.17, 0.2, 0.92)
	var base_color := _get_competitor_color(cell.owner_id)
	if cell.is_protected():
		return base_color.lightened(0.18)
	return Color(base_color.r, base_color.g, base_color.b, 0.86)

func _get_competitor_color(competitor_id: int) -> Color:
	for entry in roster:
		if int(entry.get("competitor_id", -1)) == competitor_id:
			var competitor_color: Color = entry.get("color", Color.WHITE)
			return competitor_color
	return Color.WHITE

func _reset_ownership_percentages() -> void:
	owner_percentages.clear()
	for entry in roster:
		owner_percentages[int(entry.get("competitor_id", -1))] = 0.0

func _emit_debug_summary() -> void:
	if match_config == null:
		return
	var lines := PackedStringArray()
	lines.append("Territory Grid: %dx%d" % [match_config.territory_columns, match_config.territory_rows])
	lines.append("Marbles Active: %d" % marble_actors.size())
	lines.append("Contested Cells: %d" % contested_cell_count)
	for entry in roster:
		var competitor_id := int(entry.get("competitor_id", -1))
		var display_name := String(entry.get("display_name", "Unknown"))
		var owned_percent := float(owner_percentages.get(competitor_id, 0.0)) * 100.0
		var marble_label := "Base Marble"
		var marble_definition_variant: Variant = entry.get("marble_definition", null)
		if marble_definition_variant is MarbleDefinition:
			marble_label = marble_definition_variant.display_name
		lines.append("%s (%s): %.1f%%" % [display_name, marble_label, owned_percent])
	debug_state_changed.emit(lines)
