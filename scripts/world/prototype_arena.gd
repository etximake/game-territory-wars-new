@tool
extends Node2D

class_name PrototypeArena

@export var arena_size: Vector2 = GameConstants.ARENA_DEFAULT_SIZE:
	set(value):
		arena_size = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		if is_node_ready():
			rebuild()

@export var wall_thickness: float = 64.0:
	set(value):
		wall_thickness = maxf(value, 1.0)
		if is_node_ready():
			rebuild()

@export var floor_color: Color = Color(0.08, 0.09, 0.12, 1.0):
	set(value):
		floor_color = value
		if is_node_ready():
			rebuild()

@export var border_color: Color = Color(0.42, 0.77, 0.65, 1.0):
	set(value):
		border_color = value
		if is_node_ready():
			rebuild()

@onready var floor: Polygon2D = $Floor
@onready var border: Line2D = $Border
@onready var top_wall: StaticBody2D = $Walls/TopWall
@onready var right_wall: StaticBody2D = $Walls/RightWall
@onready var bottom_wall: StaticBody2D = $Walls/BottomWall
@onready var left_wall: StaticBody2D = $Walls/LeftWall

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	var half_size := arena_size * 0.5
	var corners := PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y),
	])

	floor.polygon = corners
	floor.color = floor_color

	border.points = PackedVector2Array([
		corners[0],
		corners[1],
		corners[2],
		corners[3],
		corners[0],
	])
	border.default_color = border_color

	_configure_wall(top_wall, Vector2(0.0, -half_size.y - wall_thickness * 0.5), Vector2(arena_size.x, wall_thickness))
	_configure_wall(right_wall, Vector2(half_size.x + wall_thickness * 0.5, 0.0), Vector2(wall_thickness, arena_size.y))
	_configure_wall(bottom_wall, Vector2(0.0, half_size.y + wall_thickness * 0.5), Vector2(arena_size.x, wall_thickness))
	_configure_wall(left_wall, Vector2(-half_size.x - wall_thickness * 0.5, 0.0), Vector2(wall_thickness, arena_size.y))

func get_bounds() -> Rect2:
	var half_size := arena_size * 0.5
	return Rect2(Vector2(-half_size.x, -half_size.y), arena_size)

func _configure_wall(wall: StaticBody2D, wall_position: Vector2, wall_size: Vector2) -> void:
	wall.position = wall_position

	var collision_shape := wall.get_node("CollisionShape2D") as CollisionShape2D
	var shape := collision_shape.shape as RectangleShape2D
	shape.size = wall_size
