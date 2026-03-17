extends Camera2D

class_name PrototypeCamera

@export var padding: Vector2 = GameConstants.CAMERA_DEFAULT_PADDING
@export_range(0.25, 4.0, 0.05, "or_greater") var min_zoom_factor: float = 0.5
@export_range(0.25, 4.0, 0.05, "or_greater") var max_zoom_factor: float = 2.0

func _ready() -> void:
	add_to_group(GameConstants.GROUP_CAMERA)
	make_current()

func frame_rect(target_rect: Rect2) -> void:
	if not is_inside_tree():
		return

	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		call_deferred("frame_rect", target_rect)
		return

	position = target_rect.get_center()

	var padded_size := target_rect.size + padding * 2.0
	var zoom_factor := maxf(padded_size.x / viewport_size.x, padded_size.y / viewport_size.y)
	zoom_factor = clampf(zoom_factor, min_zoom_factor, max_zoom_factor)
	zoom = Vector2.ONE * zoom_factor
