extends RefCounted

class_name TerritoryCell

var cell_index: int = -1
var grid_position: Vector2i = Vector2i.ZERO
var owner_id: int = -1
var state: int = GameConstants.TerritoryCellState.NEUTRAL
var capture_progress: float = 0.0
var capture_target_id: int = -1
var protection_remaining_seconds: float = 0.0
var contested_by: PackedInt32Array = PackedInt32Array()

func reset() -> void:
	owner_id = -1
	state = GameConstants.TerritoryCellState.NEUTRAL
	capture_progress = 0.0
	capture_target_id = -1
	protection_remaining_seconds = 0.0
	contested_by = PackedInt32Array()

func is_protected() -> bool:
	return protection_remaining_seconds > 0.0
