extends Resource

class_name MarbleStats

@export_range(16.0, 512.0, 1.0, "or_greater") var move_speed: float = 135.0
@export_range(16.0, 1024.0, 1.0, "or_greater") var acceleration: float = 420.0
@export_range(0.0, 1024.0, 1.0, "or_greater") var friction: float = 260.0
@export_range(0.1, 10.0, 0.05, "or_greater") var mass: float = 1.0
@export_range(0.1, 10.0, 0.05, "or_greater") var collision_force: float = 1.0
@export_range(0.1, 10.0, 0.05, "or_greater") var knockback_resistance: float = 1.0
@export_range(1.0, 1000.0, 1.0, "or_greater") var durability: float = 100.0
@export_range(0.1, 5.0, 0.05, "or_greater") var defense_modifier: float = 1.0
@export_range(16.0, 512.0, 1.0, "or_greater") var body_radius: float = 24.0
@export_range(16.0, 512.0, 1.0, "or_greater") var influence_radius: float = 120.0
@export_range(0.1, 5.0, 0.05, "or_greater") var neutral_capture_rate: float = 1.0
@export_range(0.1, 5.0, 0.05, "or_greater") var enemy_reclaim_rate: float = 1.0
@export_range(0.1, 30.0, 0.1, "or_greater") var active_cooldown_seconds: float = 8.0
@export_range(0.0, 15.0, 0.1, "or_greater") var active_duration_seconds: float = 2.0
@export_range(0.0, 512.0, 1.0, "or_greater") var territory_effect_radius: float = 128.0
@export_range(0.0, 10.0, 0.05, "or_greater") var territory_effect_strength: float = 1.0
