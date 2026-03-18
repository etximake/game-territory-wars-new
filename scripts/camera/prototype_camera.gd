extends Camera2D

class_name PrototypeCamera

enum PresetMode {
	GAMEPLAY,
	SIMULATION,
}

@export var padding: Vector2 = GameConstants.CAMERA_DEFAULT_PADDING
@export_range(0.25, 4.0, 0.05, "or_greater") var min_zoom_factor: float = 0.5
@export_range(0.25, 4.0, 0.05, "or_greater") var max_zoom_factor: float = 2.0
@export_range(0.5, 1.5, 0.05, "or_greater") var readability_zoom_bias: float = 0.82
@export_range(0.5, 2.0, 0.05, "or_greater") var gameplay_zoom_bias: float = 0.82
@export_range(0.5, 2.0, 0.05, "or_greater") var simulation_zoom_bias: float = 1.08

var _framed_rect: Rect2 = Rect2()
var _preset_mode: int = PresetMode.GAMEPLAY

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

	_framed_rect = target_rect
	position = target_rect.get_center()

	var padded_size := target_rect.size + padding * 2.0
	var zoom_factor := minf(viewport_size.x / padded_size.x, viewport_size.y / padded_size.y)
	zoom_factor *= _get_active_zoom_bias()
	zoom_factor = clampf(zoom_factor, min_zoom_factor, max_zoom_factor)
	zoom = Vector2.ONE * zoom_factor

func cycle_preset() -> void:
	if _preset_mode == PresetMode.GAMEPLAY:
		set_preset_mode(PresetMode.SIMULATION)
	else:
		set_preset_mode(PresetMode.GAMEPLAY)

func set_preset_mode(mode: int) -> void:
	_preset_mode = mode
	if _framed_rect.size != Vector2.ZERO:
		frame_rect(_framed_rect)

func get_preset_mode() -> int:
	return _preset_mode

func get_preset_label() -> String:
	return "Simulation" if _preset_mode == PresetMode.SIMULATION else "Gameplay"

func _get_active_zoom_bias() -> float:
	if _preset_mode == PresetMode.SIMULATION:
		return simulation_zoom_bias
	return gameplay_zoom_bias * readability_zoom_bias / 0.82
