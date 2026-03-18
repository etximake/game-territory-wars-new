extends Node2D

class_name TerritoryController

signal ownership_changed(owner_percentages: Dictionary, contested_cells: int)
signal score_awarded(competitor_id: int, source: int, amount: float)
signal debug_state_changed(summary_lines: PackedStringArray)

const GRID_LINE_COLOR := Color(0.08, 0.1, 0.12, 0.16)
const NEUTRAL_FILL_COLOR := Color(0.18, 0.2, 0.24, 0.18)
const OWNED_FILL_ALPHA := 0.22
const PROTECTED_FILL_ALPHA := 0.28
const OWNER_BOUNDARY_ALPHA := 0.52
const OWNER_MARKER_BACKGROUND := Color(0.03, 0.04, 0.06, 0.84)
const CONTESTED_ACCENT_COLOR := Color(1.0, 0.95, 0.72, 0.66)

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

func get_priority_point_for_actor(actor: MarbleActor, from_position: Vector2) -> Vector2:
	if actor == null or cells.is_empty():
		return Vector2(INF, INF)
	var best_score := -INF
	var best_point := Vector2(INF, INF)
	var profile := actor.get_ai_role_profile()
	for cell in cells:
		var score := _score_cell_for_actor(cell, actor, from_position, profile)
		if score > best_score:
			best_score = score
			best_point = _get_cell_rect(cell).get_center()
	return best_point

func is_hotspot_near_position(position: Vector2, radius: float) -> bool:
	var cell := _get_cell_at_position(position)
	if cell != null and cell.state == GameConstants.TerritoryCellState.CONTESTED:
		return true
	for other_cell in cells:
		if other_cell.state != GameConstants.TerritoryCellState.CONTESTED:
			continue
		if _get_cell_rect(other_cell).get_center().distance_to(position) <= radius:
			return true
	return false

func get_cell_owner_id_at_position(position: Vector2) -> int:
	var cell := _get_cell_at_position(position)
	return cell.owner_id if cell != null else -1

func get_cell_state_at_position(position: Vector2) -> int:
	var cell := _get_cell_at_position(position)
	return cell.state if cell != null else GameConstants.TerritoryCellState.NEUTRAL

func _process(delta: float) -> void:
	if not is_match_running:
		return

	_update_cells(delta)
	_update_score_tick(delta)
	queue_redraw()

func _draw() -> void:
	if cells.is_empty():
		return

	var pulse := 0.55 + sin(Time.get_ticks_msec() * 0.008) * 0.22
	for cell in cells:
		var rect := _get_cell_rect(cell)
		var visual_rect := _get_visual_cell_rect(rect)
		draw_rect(visual_rect, _get_cell_fill_color(cell), true)
		if cell.state == GameConstants.TerritoryCellState.CONTESTED:
			_draw_contested_cell(visual_rect, cell, pulse)
		if cell.owner_id >= 0:
			_draw_owner_corner_marker(visual_rect, cell)
		draw_rect(rect, GRID_LINE_COLOR, false, 1.0)
	for cell in cells:
		if cell.owner_id >= 0 and cell.state != GameConstants.TerritoryCellState.CONTESTED:
			_draw_owner_boundary(_get_cell_rect(cell), cell)
		if cell.is_protected() and cell.owner_id >= 0:
			draw_rect(_get_visual_cell_rect(_get_cell_rect(cell)).grow(-2.0), Color(1.0, 1.0, 1.0, 0.72), false, 2.0)

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

func _score_cell_for_actor(cell: TerritoryCell, actor: MarbleActor, from_position: Vector2, profile: StringName) -> float:
	var rect := _get_cell_rect(cell)
	var distance_score := 1.0 - clampf(from_position.distance_to(rect.get_center()) / maxf(arena_bounds.size.length() * 0.45, 1.0), 0.0, 1.0)
	var score := distance_score * 0.7
	if cell.state == GameConstants.TerritoryCellState.CONTESTED:
		score += 3.0
	if cell.owner_id < 0:
		score += 1.0
	elif cell.owner_id != actor.competitor_id:
		score += 2.2
	else:
		score += 0.4
	if cell.is_protected() and cell.owner_id == actor.competitor_id:
		score += 0.3
	match profile:
		&"aggressive":
			if cell.owner_id >= 0 and cell.owner_id != actor.competitor_id:
				score += 1.3
			if cell.state == GameConstants.TerritoryCellState.CONTESTED:
				score += 0.8
		&"defensive":
			if cell.owner_id == actor.competitor_id:
				score += 1.2
			if cell.state == GameConstants.TerritoryCellState.CONTESTED:
				score += 1.1
		&"utility":
			if cell.state == GameConstants.TerritoryCellState.CONTESTED:
				score += 1.8
			if cell.owner_id < 0:
				score += 0.7
		&"anchor":
			if cell.owner_id == actor.competitor_id:
				score += 1.5
			if cell.is_protected():
				score += 0.8
		&"chaos":
			if cell.state == GameConstants.TerritoryCellState.CONTESTED:
				score += 2.0
			if cell.owner_id >= 0 and cell.owner_id != actor.competitor_id:
				score += 0.9
	return score

func _get_cell_at_position(position: Vector2) -> TerritoryCell:
	if cell_size == Vector2.ZERO:
		return null
	var local := position - arena_bounds.position
	var column := int(floor(local.x / cell_size.x))
	var row := int(floor(local.y / cell_size.y))
	if column < 0 or row < 0 or column >= match_config.territory_columns or row >= match_config.territory_rows:
		return null
	return cells[row * match_config.territory_columns + column]

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
	return _apply_territory_effect_modifiers(cell, result, cell_center)

func _apply_territory_effect_modifiers(cell: TerritoryCell, base_influences: Dictionary, cell_center: Vector2) -> Dictionary:
	var influences := {}
	for competitor_id_variant in base_influences.keys():
		var competitor_id := int(competitor_id_variant)
		influences[competitor_id] = (base_influences[competitor_id] as Dictionary).duplicate(true)

	for marble_actor in marble_actors:
		if not is_instance_valid(marble_actor):
			continue
		if marble_actor.global_position.distance_to(cell_center) > marble_actor.get_territory_effect_radius():
			continue
		var actor_id := marble_actor.competitor_id
		var strength := marble_actor.get_territory_effect_strength()
		match marble_actor.get_territory_effect_slot_id():
			&"territory.fire_pressure":
				if influences.has(actor_id):
					var actor_entry := influences[actor_id] as Dictionary
					actor_entry["influence"] = float(actor_entry.get("influence", 0.0)) * (1.0 + 0.22 * strength)
					if cell.owner_id != actor_id:
						actor_entry["enemy_reclaim_rate"] = float(actor_entry.get("enemy_reclaim_rate", 1.0)) * (1.0 + 0.18 * strength)
			&"territory.ice_slow_zone":
				if cell.owner_id == actor_id:
					for other_id_variant in influences.keys():
						var other_id := int(other_id_variant)
						if other_id == actor_id:
							continue
						var enemy_entry := influences[other_id] as Dictionary
						enemy_entry["influence"] = float(enemy_entry.get("influence", 0.0)) * maxf(0.45, 1.0 - 0.24 * strength)
						enemy_entry["enemy_reclaim_rate"] = float(enemy_entry.get("enemy_reclaim_rate", 1.0)) * maxf(0.4, 1.0 - 0.28 * strength)
			&"territory.magnet_resource_drift":
				if influences.size() > 1 and influences.has(actor_id):
					var magnet_entry := influences[actor_id] as Dictionary
					magnet_entry["influence"] = float(magnet_entry.get("influence", 0.0)) * (1.0 + 0.24 * strength)
					magnet_entry["neutral_capture_rate"] = float(magnet_entry.get("neutral_capture_rate", 1.0)) * (1.0 + 0.16 * strength)
			&"territory.shield_anti_recapture":
				if cell.owner_id == actor_id:
					for other_id_variant in influences.keys():
						var other_owner_id := int(other_id_variant)
						if other_owner_id == actor_id:
							continue
						var hostile_entry := influences[other_owner_id] as Dictionary
						hostile_entry["enemy_reclaim_rate"] = float(hostile_entry.get("enemy_reclaim_rate", 1.0)) * maxf(0.3, 1.0 - 0.4 * strength)
						hostile_entry["influence"] = float(hostile_entry.get("influence", 0.0)) * maxf(0.45, 1.0 - 0.18 * strength)
			&"territory.storm_push_current":
				if influences.size() > 1:
					if influences.has(actor_id):
						var storm_entry := influences[actor_id] as Dictionary
						storm_entry["influence"] = float(storm_entry.get("influence", 0.0)) * (1.0 + 0.16 * strength)
					for other_id_variant in influences.keys():
						var storm_other_id := int(other_id_variant)
						if storm_other_id == actor_id:
							continue
						var drift_entry := influences[storm_other_id] as Dictionary
						drift_entry["influence"] = float(drift_entry.get("influence", 0.0)) * maxf(0.5, 1.0 - 0.12 * strength)
	return influences

func _resolve_cell_state(cell: TerritoryCell, influences: Dictionary, delta: float) -> void:
	if influences.is_empty():
		cell.dominant_competitor_id = cell.owner_id
		cell.secondary_competitor_id = -1
		cell.contested_balance = 0.0
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
	cell.dominant_competitor_id = top_competitor_id
	cell.secondary_competitor_id = -1 if second_influence < 0.0 else _find_secondary_competitor_id(influences, top_competitor_id, second_influence)
	cell.contested_balance = 0.0 if top_influence <= 0.0 or second_influence < 0.0 else clampf(second_influence / top_influence, 0.0, 1.0)
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
		cell.capture_progress = 0.0
		cell.capture_target_id = -1
		if not is_contested:
			cell.state = GameConstants.TerritoryCellState.OWNED
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

func _get_visual_cell_rect(rect: Rect2) -> Rect2:
	var inset := clampf(minf(rect.size.x, rect.size.y) * 0.12, 2.0, 7.0)
	return rect.grow_individual(-inset, -inset, -inset, -inset)

func _get_cell_fill_color(cell: TerritoryCell) -> Color:
	if cell.state == GameConstants.TerritoryCellState.CONTESTED:
		if cell.dominant_competitor_id >= 0:
			return _get_muted_competitor_color(cell.dominant_competitor_id, 0.18)
		if cell.owner_id >= 0:
			return _get_muted_competitor_color(cell.owner_id, 0.18)
		return NEUTRAL_FILL_COLOR
	if cell.owner_id < 0:
		return NEUTRAL_FILL_COLOR
	var base_color := _get_competitor_color(cell.owner_id).lerp(Color(0.22, 0.24, 0.28, 1.0), 0.48)
	if cell.is_protected():
		base_color = base_color.lightened(0.1)
		return Color(base_color.r, base_color.g, base_color.b, PROTECTED_FILL_ALPHA)
	return Color(base_color.r, base_color.g, base_color.b, OWNED_FILL_ALPHA)

func _draw_contested_cell(rect: Rect2, cell: TerritoryCell, pulse: float) -> void:
	var primary_color := _get_competitor_color(cell.dominant_competitor_id)
	var secondary_color := _get_competitor_color(cell.secondary_competitor_id)
	var side_band_width := rect.size.x * 0.18
	var left_rect := Rect2(rect.position, Vector2(side_band_width, rect.size.y))
	var right_rect := Rect2(rect.end - Vector2(side_band_width, rect.size.y), Vector2(side_band_width, rect.size.y))
	var center_band_width := rect.size.x * 0.28
	var center_band := Rect2(rect.position + Vector2((rect.size.x - center_band_width) * 0.5, 0.0), Vector2(center_band_width, rect.size.y))
	draw_rect(left_rect, Color(primary_color.r, primary_color.g, primary_color.b, 0.24), true)
	if cell.secondary_competitor_id >= 0:
		draw_rect(right_rect, Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.24), true)
	draw_rect(center_band, Color(1.0, 0.95, 0.72, 0.12 + pulse * 0.08), true)
	var edge_color := Color(CONTESTED_ACCENT_COLOR.r, CONTESTED_ACCENT_COLOR.g, CONTESTED_ACCENT_COLOR.b, 0.46 + pulse * 0.18)
	draw_rect(rect.grow(-1.0), edge_color, false, 2.0)
	var tension_alpha := lerpf(0.24, 0.56, cell.contested_balance)
	draw_line(rect.position + Vector2(5.0, 5.0), rect.end - Vector2(5.0, 5.0), Color(1.0, 0.95, 0.72, tension_alpha), 2.0)
	if cell.secondary_competitor_id >= 0:
		draw_line(Vector2(rect.position.x + 5.0, rect.end.y - 5.0), Vector2(rect.end.x - 5.0, rect.position.y + 5.0), Color(1.0, 0.95, 0.72, tension_alpha * 0.8), 1.5)

func _draw_owner_corner_marker(rect: Rect2, cell: TerritoryCell) -> void:
	var marker_size := clampf(minf(rect.size.x, rect.size.y) * 0.18, 8.0, 14.0)
	var marker_rect := Rect2(rect.position + Vector2(4.0, 4.0), Vector2(marker_size, marker_size))
	var owner_color := _get_competitor_color(cell.owner_id)
	draw_rect(marker_rect, OWNER_MARKER_BACKGROUND, true)
	draw_rect(marker_rect.grow(-2.0), owner_color, true)
	if cell.capture_progress > 0.0 and cell.capture_target_id >= 0:
		var progress_width := clampf(cell.capture_progress, 0.0, 1.0) * (rect.size.x - 10.0)
		var progress_rect := Rect2(rect.position + Vector2(5.0, rect.size.y - 7.0), Vector2(progress_width, 3.0))
		var target_color := _get_competitor_color(cell.capture_target_id)
		draw_rect(progress_rect, Color(target_color.r, target_color.g, target_color.b, 0.88), true)

func _draw_owner_boundary(rect: Rect2, cell: TerritoryCell) -> void:
	var owner_color := _get_competitor_color(cell.owner_id)
	var edge_color := Color(owner_color.r, owner_color.g, owner_color.b, OWNER_BOUNDARY_ALPHA)
	var line_width := 2.4 if cell.is_protected() else 1.7
	if _should_draw_owner_edge(cell.grid_position + Vector2i(-1, 0), cell.owner_id):
		draw_line(rect.position, Vector2(rect.position.x, rect.end.y), edge_color, line_width)
	if _should_draw_owner_edge(cell.grid_position + Vector2i(1, 0), cell.owner_id):
		draw_line(Vector2(rect.end.x, rect.position.y), rect.end, edge_color, line_width)
	if _should_draw_owner_edge(cell.grid_position + Vector2i(0, -1), cell.owner_id):
		draw_line(rect.position, Vector2(rect.end.x, rect.position.y), edge_color, line_width)
	if _should_draw_owner_edge(cell.grid_position + Vector2i(0, 1), cell.owner_id):
		draw_line(Vector2(rect.position.x, rect.end.y), rect.end, edge_color, line_width)

func _should_draw_owner_edge(grid_position: Vector2i, owner_id: int) -> bool:
	var neighbor := _get_cell_by_grid_position(grid_position)
	if neighbor == null:
		return false
	return neighbor.owner_id != owner_id or neighbor.state == GameConstants.TerritoryCellState.CONTESTED

func _get_cell_by_grid_position(grid_position: Vector2i) -> TerritoryCell:
	if grid_position.x < 0 or grid_position.y < 0:
		return null
	if grid_position.x >= match_config.territory_columns or grid_position.y >= match_config.territory_rows:
		return null
	return cells[grid_position.y * match_config.territory_columns + grid_position.x]

func _get_muted_competitor_color(competitor_id: int, alpha: float) -> Color:
	var base_color := _get_competitor_color(competitor_id).lerp(Color(0.24, 0.26, 0.3, 1.0), 0.42)
	return Color(base_color.r, base_color.g, base_color.b, alpha)

func _find_secondary_competitor_id(influences: Dictionary, top_competitor_id: int, second_influence: float) -> int:
	for competitor_id_variant in influences.keys():
		var competitor_id := int(competitor_id_variant)
		if competitor_id == top_competitor_id:
			continue
		var metrics: Dictionary = influences[competitor_id]
		if is_equal_approx(float(metrics.get("influence", 0.0)), second_influence):
			return competitor_id
	return -1

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
		var weapon_label := "No Weapon"
		var weapon_variant: Variant = entry.get("weapon_definition", null)
		if weapon_variant is WeaponDefinition:
			weapon_label = weapon_variant.display_name
		lines.append("%s (%s + %s): %.1f%%" % [display_name, marble_label, weapon_label, owned_percent])
	debug_state_changed.emit(lines)
