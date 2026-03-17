extends Node2D

class_name TerritoryDebugAgent

@export var radius: float = 24.0
@export var influence_radius: float = 115.0

var competitor_id: int = -1
var display_name: String = ""
var competitor_color: Color = Color.WHITE
var bounds: Rect2 = Rect2()
var velocity: Vector2 = Vector2.ZERO

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group(GameConstants.GROUP_TERRITORY_AGENT)
	queue_redraw()

func configure(roster_entry: Dictionary, arena_bounds: Rect2, config: MatchConfig, seed: int) -> void:
	competitor_id = int(roster_entry.get("competitor_id", -1))
	display_name = String(roster_entry.get("display_name", "Unknown"))
	competitor_color = Color(roster_entry.get("color", Color.WHITE))
	bounds = arena_bounds.grow(-maxf(config.debug_agent_influence_radius, config.debug_agent_radius) * 0.6)
	radius = config.debug_agent_radius
	influence_radius = config.debug_agent_influence_radius
	_rng.seed = seed
	position = _random_point_in_bounds()
	velocity = _random_velocity(config.debug_agent_speed_min, config.debug_agent_speed_max)
	queue_redraw()

func reset_for_match(seed: int, config: MatchConfig) -> void:
	_rng.seed = seed
	if bounds.size == Vector2.ZERO:
		return
	position = _random_point_in_bounds()
	velocity = _random_velocity(config.debug_agent_speed_min, config.debug_agent_speed_max)

func step(delta: float, config: MatchConfig) -> void:
	if bounds.size == Vector2.ZERO:
		return

	position += velocity * delta
	var bounced := false
	if position.x < bounds.position.x or position.x > bounds.end.x:
		velocity.x *= -1.0
		position.x = clampf(position.x, bounds.position.x, bounds.end.x)
		bounced = true
	if position.y < bounds.position.y or position.y > bounds.end.y:
		velocity.y *= -1.0
		position.y = clampf(position.y, bounds.position.y, bounds.end.y)
		bounced = true
	if bounced and velocity.length() > 0.0:
		velocity = velocity.normalized() * _rng.randf_range(config.debug_agent_speed_min, config.debug_agent_speed_max)

func _draw() -> void:
	draw_circle(Vector2.ZERO, influence_radius, Color(competitor_color.r, competitor_color.g, competitor_color.b, 0.08))
	draw_circle(Vector2.ZERO, radius, competitor_color)
	draw_arc(Vector2.ZERO, radius + 3.0, 0.0, TAU, 20, Color.WHITE, 2.0)

func _random_point_in_bounds() -> Vector2:
	return Vector2(
		_rng.randf_range(bounds.position.x, bounds.end.x),
		_rng.randf_range(bounds.position.y, bounds.end.y)
	)

func _random_velocity(speed_min: float, speed_max: float) -> Vector2:
	var angle := _rng.randf_range(0.0, TAU)
	var speed := _rng.randf_range(speed_min, speed_max)
	return Vector2.RIGHT.rotated(angle) * speed
