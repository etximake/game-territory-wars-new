extends Resource

class_name MarbleDefinition

@export var marble_id: StringName = &"base"
@export var display_name: String = "Base Marble"
@export var role: String = "Generalist"
@export_multiline var core_fantasy: String = ""
@export var stats: MarbleStats
@export var passive_slot_id: StringName = &"passive.none"
@export var active_slot_id: StringName = &"active.none"
@export var territory_effect_slot_id: StringName = &"territory.none"
@export var weakness_hook_id: StringName = &"counter.none"
@export var visual_profile_id: StringName = &"visual.base"
@export var visual_primary_color: Color = Color("f5f5f5")
@export var visual_secondary_color: Color = Color("2d3142")
@export var trail_color: Color = Color("ffffff")
@export_multiline var readability_notes: String = ""

func get_stats() -> MarbleStats:
	if stats == null:
		stats = MarbleStats.new()
	return stats
