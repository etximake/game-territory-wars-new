extends CharacterBody2D

class_name MarbleActor

@export var marble_definition: MarbleDefinition

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var competitor_id: int = -1
var display_name: String = ""
var competitor_color: Color = Color.WHITE
var arena_bounds: Rect2 = Rect2()
var match_config: MatchConfig
var is_match_running: bool = false

var _rng := RandomNumberGenerator.new()
var _move_target: Vector2 = Vector2.ZERO
var _trail_points: Array[Vector2] = []
var _bounce_cooldown_seconds: float = 0.0

func _ready() -> void:
	add_to_group(GameConstants.GROUP_MARBLE)
	collision_layer = GameConstants.layer_bit(GameConstants.PhysicsLayer.MARBLE)
	collision_mask = GameConstants.layer_bit(GameConstants.PhysicsLayer.WORLD) | GameConstants.layer_bit(GameConstants.PhysicsLayer.MARBLE)
	set_physics_process(false)
	_refresh_shape()
	queue_redraw()

func configure(roster_entry: Dictionary, bounds: Rect2, config: MatchConfig, seed: int) -> void:
	competitor_id = int(roster_entry.get("competitor_id", -1))
	display_name = String(roster_entry.get("display_name", "Unknown"))
	competitor_color = Color(roster_entry.get("color", Color.WHITE))
	match_config = config
	var definition_variant: Variant = roster_entry.get("marble_definition", null)
	if definition_variant is MarbleDefinition:
		marble_definition = definition_variant
	arena_bounds = _build_safe_bounds(bounds)
	_rng.seed = seed
	_refresh_shape()
	reset_for_match(seed, config)

func reset_for_match(seed: int, config: MatchConfig) -> void:
	match_config = config
	_rng.seed = seed
	global_position = _random_point_in_bounds()
	_move_target = _random_point_in_bounds()
	velocity = _random_direction() * _rng.randf_range(get_stats().move_speed * 0.4, get_stats().move_speed * 0.75)
	_bounce_cooldown_seconds = 0.0
	_reset_trail()
	queue_redraw()

func start_match() -> void:
	is_match_running = true
	set_physics_process(true)

func stop_match() -> void:
	is_match_running = false
	set_physics_process(false)
	velocity = Vector2.ZERO
	_reset_trail()
	queue_redraw()

func get_stats() -> MarbleStats:
	if marble_definition == null:
		marble_definition = MarbleDefinition.new()
	return marble_definition.get_stats()

func get_influence_radius() -> float:
	return get_stats().influence_radius

func get_influence_at(world_point: Vector2) -> float:
	var influence_radius := get_influence_radius()
	if influence_radius <= 0.0:
		return 0.0
	var distance := global_position.distance_to(world_point)
	if distance > influence_radius:
		return 0.0
	var normalized := 1.0 - (distance / influence_radius)
	return maxf(normalized, 0.15)

func get_neutral_capture_rate() -> float:
	return get_stats().neutral_capture_rate

func get_enemy_reclaim_rate() -> float:
	return get_stats().enemy_reclaim_rate

func get_passive_slot_id() -> StringName:
	return marble_definition.passive_slot_id if marble_definition != null else &"passive.none"

func get_active_slot_id() -> StringName:
	return marble_definition.active_slot_id if marble_definition != null else &"active.none"

func get_territory_effect_slot_id() -> StringName:
	return marble_definition.territory_effect_slot_id if marble_definition != null else &"territory.none"

func get_weakness_hook_id() -> StringName:
	return marble_definition.weakness_hook_id if marble_definition != null else &"counter.none"

func _physics_process(delta: float) -> void:
	if not is_match_running:
		return

	_bounce_cooldown_seconds = maxf(_bounce_cooldown_seconds - delta, 0.0)
	_update_navigation(delta)
	move_and_slide()
	_record_trail_point()
	if get_slide_collision_count() > 0:
		_handle_slide_collisions()
	queue_redraw()

func _draw() -> void:
	var primary_color := Color("f5f5f5")
	var secondary_color := competitor_color.darkened(0.3)
	var trail_color := Color(competitor_color.r, competitor_color.g, competitor_color.b, 0.45)
	if marble_definition != null:
		primary_color = marble_definition.visual_primary_color
		secondary_color = marble_definition.visual_secondary_color
		trail_color = marble_definition.trail_color

	if _trail_points.size() >= 2:
		var local_points := PackedVector2Array()
		for point in _trail_points:
			local_points.append(to_local(point))
		draw_polyline(local_points, Color(trail_color.r, trail_color.g, trail_color.b, 0.35), 4.0, true)

	var radius := get_stats().body_radius
	draw_circle(Vector2.ZERO, radius, Color(0.08, 0.1, 0.14, 0.92))
	draw_circle(Vector2.ZERO, radius - 3.0, Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.95))
	draw_circle(Vector2.ZERO, radius * 0.56, primary_color)
	draw_arc(Vector2.ZERO, radius + 4.0, -PI * 0.65, PI * 0.65, 20, competitor_color, 3.0)
	draw_circle(Vector2.ZERO, radius * 0.18, Color.WHITE)

func _update_navigation(delta: float) -> void:
	var stats := get_stats()
	if global_position.distance_to(_move_target) <= stats.body_radius * 1.5:
		_move_target = _random_point_in_bounds()
	elif _rng.randf() < delta * 0.2:
		_move_target = _random_point_in_bounds()

	var desired_direction := global_position.direction_to(_move_target)
	var center := arena_bounds.get_center()
	var distance_to_center := global_position.distance_to(center)
	var max_center_distance := minf(arena_bounds.size.x, arena_bounds.size.y) * 0.35
	if distance_to_center > max_center_distance:
		desired_direction = (desired_direction + global_position.direction_to(center) * 1.35).normalized()

	var desired_velocity := desired_direction * stats.move_speed
	velocity = velocity.move_toward(desired_velocity, stats.acceleration * delta)
	if desired_direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, stats.friction * delta)

func _handle_slide_collisions() -> void:
	if _bounce_cooldown_seconds > 0.0:
		return

	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		if collision == null:
			continue
		velocity = velocity.bounce(collision.get_normal()) * 0.92
		_move_target = _random_point_in_bounds()
		_bounce_cooldown_seconds = 0.15
		break

func _refresh_shape() -> void:
	if collision_shape == null:
		return
	var shape := collision_shape.shape as CircleShape2D
	if shape == null:
		shape = CircleShape2D.new()
		collision_shape.shape = shape
	shape.radius = get_stats().body_radius

func _build_safe_bounds(bounds: Rect2) -> Rect2:
	var margin := maxf(get_stats().body_radius + 12.0, get_influence_radius() * 0.2)
	return bounds.grow_individual(-margin, -margin, -margin, -margin)

func _random_point_in_bounds() -> Vector2:
	if arena_bounds.size == Vector2.ZERO:
		return Vector2.ZERO
	return Vector2(
		_rng.randf_range(arena_bounds.position.x, arena_bounds.end.x),
		_rng.randf_range(arena_bounds.position.y, arena_bounds.end.y)
	)

func _random_direction() -> Vector2:
	return Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU))

func _record_trail_point() -> void:
	_trail_points.append(global_position)
	var max_points := 12
	while _trail_points.size() > max_points:
		_trail_points.pop_front()

func _reset_trail() -> void:
	_trail_points.clear()
	_trail_points.append(global_position)
