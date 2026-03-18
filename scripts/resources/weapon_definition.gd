extends Resource

class_name WeaponDefinition

@export var weapon_id: StringName = &"weapon.none"
@export var display_name: String = "Prototype Weapon"
@export var category: String = "pressure"
@export_range(0.0, 200.0, 0.5, "or_greater") var damage: float = 16.0
@export_range(32.0, 1024.0, 1.0, "or_greater") var range: float = 220.0
@export_range(0.1, 15.0, 0.1, "or_greater") var cooldown_seconds: float = 2.0
@export_range(0.0, 2048.0, 1.0, "or_greater") var impact_force: float = 180.0
@export_range(0.0, 512.0, 1.0, "or_greater") var splash_radius: float = 0.0
@export_range(0.0, 5.0, 0.05, "or_greater") var pressure_bonus: float = 0.2
@export_range(0.0, 10.0, 0.1, "or_greater") var pressure_duration_seconds: float = 1.2
@export_range(0.0, 10.0, 0.1, "or_greater") var slow_duration_seconds: float = 0.0
@export_range(0.2, 1.0, 0.05, "or_greater") var slow_multiplier: float = 1.0
@export_range(0.0, 2048.0, 1.0, "or_greater") var pull_force: float = 0.0
@export_range(0.0, 10.0, 0.1, "or_greater") var guard_duration_seconds: float = 0.0
@export_range(0.0, 1.0, 0.05, "or_greater") var guard_strength: float = 0.0
@export_range(0.0, 5.0, 0.05, "or_greater") var influence_bonus: float = 0.0
@export var readability_color: Color = Color.WHITE
@export_multiline var readability_notes: String = ""
