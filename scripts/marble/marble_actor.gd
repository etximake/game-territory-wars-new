extends CharacterBody2D

class_name MarbleActor

signal eliminated(attacker_id: int, victim_id: int)
signal respawned(victim_id: int)

const ACTIVE_RANGE_FACTOR := 1.35
const ACTIVE_TRIGGER_RANDOMNESS := 0.18
const DEFAULT_WEAPON_RANGE := 220.0
const DEFAULT_WEAPON_COOLDOWN := 2.4
const TRAIL_POINT_COUNT := 10
const LABEL_FONT_SIZE := 12
const SMALL_FONT_SIZE := 10

@export var marble_definition: MarbleDefinition

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var competitor_id: int = -1
var display_name: String = ""
var competitor_color: Color = Color.WHITE
var arena_bounds: Rect2 = Rect2()
var match_config: MatchConfig
var weapon_definition: WeaponDefinition
var is_match_running: bool = false

var _rng := RandomNumberGenerator.new()
var _move_target: Vector2 = Vector2.ZERO
var _trail_points: Array[Vector2] = []
var _bounce_cooldown_seconds: float = 0.0
var _active_cooldown_remaining: float = 0.0
var _weapon_cooldown_remaining: float = 0.0
var _overheat_remaining: float = 0.0
var _guard_remaining: float = 0.0
var _guard_strength: float = 0.0
var _slow_remaining: float = 0.0
var _slow_multiplier: float = 1.0
var _pressure_remaining: float = 0.0
var _pressure_bonus: float = 0.0
var _focus_remaining: float = 0.0
var _focus_bonus: float = 0.0
var _magnet_field_remaining: float = 0.0
var _storm_field_remaining: float = 0.0
var _impact_flash_remaining: float = 0.0
var _current_durability: float = 0.0
var _respawn_remaining: float = 0.0
var _is_eliminated: bool = false
var _last_attacker_id: int = -1
var _is_leader: bool = false
var _territory_share: float = 0.0
var _score_total: float = 0.0

func _ready() -> void:
	add_to_group(GameConstants.GROUP_MARBLE)
	collision_layer = GameConstants.layer_bit(GameConstants.PhysicsLayer.MARBLE)
	collision_mask = GameConstants.layer_bit(GameConstants.PhysicsLayer.WORLD) | GameConstants.layer_bit(GameConstants.PhysicsLayer.MARBLE)
	z_index = 12
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
	var weapon_variant: Variant = roster_entry.get("weapon_definition", null)
	if weapon_variant is WeaponDefinition:
		weapon_definition = weapon_variant
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
	_active_cooldown_remaining = _rng.randf_range(0.4, maxf(get_stats().active_cooldown_seconds, 0.5))
	_weapon_cooldown_remaining = _rng.randf_range(0.25, maxf(get_weapon_cooldown_seconds(), 0.4))
	_overheat_remaining = 0.0
	_guard_remaining = 0.0
	_guard_strength = 0.0
	_slow_remaining = 0.0
	_slow_multiplier = 1.0
	_pressure_remaining = 0.0
	_pressure_bonus = 0.0
	_focus_remaining = 0.0
	_focus_bonus = 0.0
	_magnet_field_remaining = 0.0
	_storm_field_remaining = 0.0
	_impact_flash_remaining = 0.0
	_current_durability = get_stats().durability
	_respawn_remaining = 0.0
	_is_eliminated = false
	_last_attacker_id = -1
	_is_leader = false
	_territory_share = 0.0
	_score_total = 0.0
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

func update_spectator_state(is_leader_value: bool, territory_share_value: float, score_total_value: float) -> void:
	_is_leader = is_leader_value
	_territory_share = territory_share_value
	_score_total = score_total_value
	queue_redraw()

func get_stats() -> MarbleStats:
	if marble_definition == null:
		marble_definition = MarbleDefinition.new()
	return marble_definition.get_stats()

func get_current_durability() -> float:
	return _current_durability

func is_available_for_territory() -> bool:
	return is_match_running and not _is_eliminated

func is_eliminated() -> bool:
	return _is_eliminated

func get_respawn_remaining() -> float:
	return _respawn_remaining

func get_ai_role_profile() -> StringName:
	match get_territory_effect_slot_id():
		&"territory.fire_pressure":
			return &"aggressive"
		&"territory.ice_slow_zone":
			return &"defensive"
		&"territory.magnet_resource_drift":
			return &"utility"
		&"territory.shield_anti_recapture":
			return &"anchor"
		&"territory.storm_push_current":
			return &"chaos"
		_:
			return &"generalist"

func get_core_short_label() -> String:
	match get_territory_effect_slot_id():
		&"territory.fire_pressure":
			return "FIR"
		&"territory.ice_slow_zone":
			return "ICE"
		&"territory.magnet_resource_drift":
			return "MAG"
		&"territory.shield_anti_recapture":
			return "SHD"
		&"territory.storm_push_current":
			return "STM"
		_:
			return "MAR"

func get_active_readability_label() -> String:
	if _is_eliminated:
		return "OUT"
	if _overheat_remaining > 0.0:
		return "OVERHEAT"
	if _guard_remaining > 0.0:
		return "GUARD"
	if _magnet_field_remaining > 0.0:
		return "PULL"
	if _storm_field_remaining > 0.0:
		return "SURGE"
	if _slow_remaining > 0.0:
		return "SLOWED"
	return ""

func get_influence_radius() -> float:
	var radius := get_stats().influence_radius
	if _overheat_remaining > 0.0:
		radius *= 1.18
	if _focus_remaining > 0.0:
		radius *= 1.0 + _focus_bonus
	if _magnet_field_remaining > 0.0:
		radius *= 1.08
	return radius

func get_territory_effect_radius() -> float:
	return get_stats().territory_effect_radius

func get_territory_effect_strength() -> float:
	var strength := get_stats().territory_effect_strength
	if _overheat_remaining > 0.0 and get_territory_effect_slot_id() == &"territory.fire_pressure":
		strength *= 1.2
	if _guard_remaining > 0.0 and get_territory_effect_slot_id() == &"territory.shield_anti_recapture":
		strength *= 1.15
	return strength

func get_influence_at(world_point: Vector2) -> float:
	if _is_eliminated:
		return 0.0
	var influence_radius := get_influence_radius()
	if influence_radius <= 0.0:
		return 0.0
	var distance := global_position.distance_to(world_point)
	if distance > influence_radius:
		return 0.0
	var normalized := 1.0 - (distance / influence_radius)
	var influence := maxf(normalized, 0.15)
	if _pressure_remaining > 0.0:
		influence *= 1.0 + _pressure_bonus
	if _slow_remaining > 0.0:
		influence *= lerpf(0.82, 0.96, _slow_multiplier)
	return influence

func get_neutral_capture_rate() -> float:
	var rate := get_stats().neutral_capture_rate
	if _overheat_remaining > 0.0:
		rate *= 1.16
	if _pressure_remaining > 0.0:
		rate *= 1.0 + minf(_pressure_bonus * 0.45, 0.35)
	return rate

func get_enemy_reclaim_rate() -> float:
	var rate := get_stats().enemy_reclaim_rate
	if _focus_remaining > 0.0:
		rate *= 1.0 + minf(_focus_bonus * 0.35, 0.3)
	return rate

func get_passive_slot_id() -> StringName:
	return marble_definition.passive_slot_id if marble_definition != null else &"passive.none"

func get_active_slot_id() -> StringName:
	return marble_definition.active_slot_id if marble_definition != null else &"active.none"

func get_territory_effect_slot_id() -> StringName:
	return marble_definition.territory_effect_slot_id if marble_definition != null else &"territory.none"

func get_weakness_hook_id() -> StringName:
	return marble_definition.weakness_hook_id if marble_definition != null else &"counter.none"

func get_weapon_id() -> StringName:
	return weapon_definition.weapon_id if weapon_definition != null else &"weapon.none"

func get_weapon_display_name() -> String:
	return weapon_definition.display_name if weapon_definition != null else "No Weapon"

func get_weapon_range() -> float:
	if weapon_definition == null:
		return maxf(get_stats().influence_radius * 1.15, DEFAULT_WEAPON_RANGE)
	return weapon_definition.range

func get_weapon_cooldown_seconds() -> float:
	if weapon_definition == null:
		return DEFAULT_WEAPON_COOLDOWN
	return weapon_definition.cooldown_seconds

func _physics_process(delta: float) -> void:
	if not is_match_running:
		return

	_tick_timers(delta)
	if _is_eliminated:
		_update_respawn(delta)
		queue_redraw()
		return

	_maybe_trigger_active(delta)
	_maybe_fire_weapon()
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
	var weapon_color := Color(competitor_color.r, competitor_color.g, competitor_color.b, 0.42)
	if marble_definition != null:
		primary_color = marble_definition.visual_primary_color
		secondary_color = marble_definition.visual_secondary_color
		trail_color = marble_definition.trail_color
	if weapon_definition != null:
		weapon_color = weapon_definition.readability_color

	if _trail_points.size() >= 2:
		var local_points := PackedVector2Array()
		for point in _trail_points:
			local_points.append(to_local(point))
		var trail_width := 4.0
		if _overheat_remaining > 0.0:
			trail_width = 5.0
		elif _storm_field_remaining > 0.0:
			trail_width = 5.0
		draw_polyline(local_points, Color(trail_color.r, trail_color.g, trail_color.b, 0.1), trail_width, true)

	var radius := get_stats().body_radius * 1.34
	var shell_color := Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.95)
	var core_color := primary_color
	if _impact_flash_remaining > 0.0:
		core_color = core_color.lightened(0.25)
	if _guard_remaining > 0.0:
		shell_color = shell_color.lightened(0.18)
	if _slow_remaining > 0.0:
		core_color = core_color.lerp(Color(0.9, 0.96, 1.0), 0.35)
	if _is_eliminated:
		shell_color = shell_color.darkened(0.45)
		core_color = core_color.darkened(0.6)

	draw_circle(Vector2(2.0, 4.0), radius + 3.0, Color(0.01, 0.02, 0.03, 0.32))
	draw_circle(Vector2.ZERO, radius + 1.5, Color(0.03, 0.04, 0.06, 0.96))
	draw_circle(Vector2.ZERO, radius - 3.0, shell_color)
	draw_circle(Vector2.ZERO, radius * 0.56, core_color)
	draw_arc(Vector2.ZERO, radius + 3.5, 0.0, TAU, 36, Color(1.0, 1.0, 1.0, 0.46), 1.8)
	draw_arc(Vector2.ZERO, radius + 4.0, -PI * 0.65, PI * 0.65, 20, competitor_color, 3.0)
	draw_arc(Vector2.ZERO, radius + 7.0, PI * 0.78, PI * 1.32, 10, Color(weapon_color.r, weapon_color.g, weapon_color.b, 0.72), 3.0)
	if _is_leader:
		draw_arc(Vector2.ZERO, radius + 15.0, -PI * 0.85, PI * 0.85, 28, Color(1.0, 0.93, 0.48, 0.95), 3.0)
	if get_passive_slot_id() == &"passive.shield_knockback_guard" or _guard_remaining > 0.0:
		_draw_guard_hex(radius + 9.0, Color(0.86, 1.0, 0.9, 0.72))
	if get_passive_slot_id() == &"passive.magnet_pickup_pull":
		draw_arc(Vector2.ZERO, radius + 8.0, 0.0, TAU, 24, Color(0.66, 0.84, 1.0, 0.38), 2.0)
	if get_passive_slot_id() == &"passive.storm_deflect":
		draw_arc(Vector2.ZERO, radius + 11.0, PI * 0.1, PI * 1.45, 18, Color(1.0, 0.94, 0.72, 0.48), 2.0)
	draw_circle(Vector2.ZERO, radius * 0.18, Color.WHITE)
	draw_arc(Vector2.ZERO, radius + 1.5, 0.0, TAU, 32, Color(1.0, 1.0, 1.0, 0.34), 1.5)
	var glyph_font := ThemeDB.fallback_font
	if glyph_font != null:
		var glyph_text := get_core_glyph()
		var glyph_size := glyph_font.get_string_size(glyph_text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE + 2)
		var glyph_pos := Vector2(-glyph_size.x * 0.5, glyph_size.y * 0.3)
		draw_string_outline(glyph_font, glyph_pos, glyph_text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE + 2, 2, Color(0.03, 0.04, 0.06, 0.96))
		draw_string(glyph_font, glyph_pos, glyph_text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE + 2, Color(1, 1, 1, 0.95))
	var durability_ratio := 0.0 if get_stats().durability <= 0.0 else clampf(_current_durability / get_stats().durability, 0.0, 1.0)
	draw_arc(Vector2.ZERO, radius + 12.0, PI * 1.05, PI * (1.05 + durability_ratio * 1.3), 24, Color(1.0, 1.0, 1.0, 0.65), 2.0)
	if _is_eliminated:
		draw_line(Vector2(-radius * 0.55, -radius * 0.55), Vector2(radius * 0.55, radius * 0.55), Color(1, 1, 1, 0.7), 2.0)
		draw_line(Vector2(-radius * 0.55, radius * 0.55), Vector2(radius * 0.55, -radius * 0.55), Color(1, 1, 1, 0.7), 2.0)
	_draw_readability_labels(radius)

func _draw_readability_labels(radius: float) -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var show_name := true
	if show_name:
		var name_text := get_core_short_label()
		var name_width := font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE).x
		var name_pos := Vector2(-name_width * 0.5, -radius - 16.0)
		var name_bg := Rect2(Vector2(name_pos.x - 5.0, name_pos.y - LABEL_FONT_SIZE + 2.0), Vector2(name_width + 10.0, LABEL_FONT_SIZE + 6.0))
		draw_rect(name_bg, Color(0.03, 0.04, 0.06, 0.72), true)
		draw_string_outline(font, name_pos, name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE, 2, Color(0.03, 0.04, 0.06, 0.92))
		draw_string(font, name_pos, name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE, Color(1, 1, 1, 0.92))
	var active_text := get_active_readability_label()
	if active_text != "":
		var active_width := font.get_string_size(active_text, HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL_FONT_SIZE).x
		var active_pos := Vector2(-active_width * 0.5, radius + 22.0)
		var active_color := get_active_readability_color()
		var active_bg := Rect2(Vector2(active_pos.x - 5.0, active_pos.y - SMALL_FONT_SIZE + 2.0), Vector2(active_width + 10.0, SMALL_FONT_SIZE + 6.0))
		draw_rect(active_bg, Color(0.03, 0.04, 0.06, 0.66), true)
		draw_string_outline(font, active_pos, active_text, HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL_FONT_SIZE, 2, Color(0.03, 0.04, 0.06, 0.92))
		draw_string(font, active_pos, active_text, HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL_FONT_SIZE, active_color)
	if _is_leader:
		var lead_text := "LEAD"
		var lead_width := font.get_string_size(lead_text, HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL_FONT_SIZE).x
		var lead_pos := Vector2(-lead_width * 0.5, -radius - 30.0)
		var lead_bg := Rect2(Vector2(lead_pos.x - 5.0, lead_pos.y - SMALL_FONT_SIZE + 2.0), Vector2(lead_width + 10.0, SMALL_FONT_SIZE + 6.0))
		draw_rect(lead_bg, Color(0.36, 0.26, 0.04, 0.78), true)
		draw_string_outline(font, lead_pos, lead_text, HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL_FONT_SIZE, 2, Color(0.1, 0.08, 0.02, 0.95))
		draw_string(font, lead_pos, lead_text, HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL_FONT_SIZE, Color(1.0, 0.93, 0.52, 0.98))

func _draw_guard_hex(radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(6):
		var angle := TAU * float(index) / 6.0 - PI * 0.5
		points.append(Vector2.RIGHT.rotated(angle) * radius)
	points.append(points[0])
	draw_polyline(points, color, 2.0, true)

func get_core_glyph() -> String:
	match get_territory_effect_slot_id():
		&"territory.fire_pressure":
			return "F"
		&"territory.ice_slow_zone":
			return "I"
		&"territory.magnet_resource_drift":
			return "M"
		&"territory.shield_anti_recapture":
			return "S"
		&"territory.storm_push_current":
			return "T"
		_:
			return "?"

func get_active_readability_color() -> Color:
	if _is_eliminated:
		return Color(1, 0.8, 0.8, 0.95)
	if _overheat_remaining > 0.0:
		return Color(1.0, 0.63, 0.38, 0.98)
	if _guard_remaining > 0.0:
		return Color(0.78, 1.0, 0.86, 0.98)
	if _magnet_field_remaining > 0.0:
		return Color(0.68, 0.88, 1.0, 0.98)
	if _storm_field_remaining > 0.0:
		return Color(1.0, 0.93, 0.66, 0.98)
	if _slow_remaining > 0.0:
		return Color(0.82, 0.92, 1.0, 0.98)
	return Color(1, 0.96, 0.72, 0.95)

func _tick_timers(delta: float) -> void:
	_bounce_cooldown_seconds = maxf(_bounce_cooldown_seconds - delta, 0.0)
	_active_cooldown_remaining = maxf(_active_cooldown_remaining - delta, 0.0)
	_weapon_cooldown_remaining = maxf(_weapon_cooldown_remaining - delta, 0.0)
	_overheat_remaining = maxf(_overheat_remaining - delta, 0.0)
	_guard_remaining = maxf(_guard_remaining - delta, 0.0)
	_slow_remaining = maxf(_slow_remaining - delta, 0.0)
	_pressure_remaining = maxf(_pressure_remaining - delta, 0.0)
	_focus_remaining = maxf(_focus_remaining - delta, 0.0)
	_magnet_field_remaining = maxf(_magnet_field_remaining - delta, 0.0)
	_storm_field_remaining = maxf(_storm_field_remaining - delta, 0.0)
	_impact_flash_remaining = maxf(_impact_flash_remaining - delta, 0.0)
	if _guard_remaining <= 0.0:
		_guard_strength = 0.0
	if _slow_remaining <= 0.0:
		_slow_multiplier = 1.0
	if _pressure_remaining <= 0.0:
		_pressure_bonus = 0.0
	if _focus_remaining <= 0.0:
		_focus_bonus = 0.0

func _update_respawn(delta: float) -> void:
	if not match_config.use_respawn_elimination:
		return
	_respawn_remaining = maxf(_respawn_remaining - delta, 0.0)
	if _respawn_remaining > 0.0:
		return
	_is_eliminated = false
	_current_durability = get_stats().durability
	global_position = _random_point_in_bounds()
	_move_target = _random_point_in_bounds()
	velocity = _random_direction() * _rng.randf_range(get_stats().move_speed * 0.25, get_stats().move_speed * 0.45)
	apply_guard(0.9, 0.28)
	_focus_bonus = 0.0
	_focus_remaining = 0.0
	_pressure_bonus = 0.0
	_pressure_remaining = 0.0
	_reset_trail()
	respawned.emit(competitor_id)

func _maybe_trigger_active(delta: float) -> void:
	if _active_cooldown_remaining > 0.0:
		return
	var trigger_range := get_stats().territory_effect_radius * ACTIVE_RANGE_FACTOR
	var target := _find_nearest_enemy(trigger_range)
	var territory_hotspot := false
	var territory := _get_territory_controller()
	if territory != null:
		territory_hotspot = territory.is_hotspot_near_position(global_position, get_stats().territory_effect_radius)
	if target == null and not territory_hotspot and _rng.randf() > delta * ACTIVE_TRIGGER_RANDOMNESS:
		return

	match get_active_slot_id():
		&"active.fire_overheat_burst":
			_overheat_remaining = maxf(_overheat_remaining, get_stats().active_duration_seconds)
			_pressure_bonus = maxf(_pressure_bonus, 0.24)
			_pressure_remaining = maxf(_pressure_remaining, get_stats().active_duration_seconds)
			if target != null:
				var direction := global_position.direction_to(target.global_position)
				velocity += direction * 120.0
		&"active.ice_freeze_pulse":
			for enemy in _get_enemies_in_radius(get_stats().territory_effect_radius):
				enemy.receive_attack_hit(competitor_id, 7.0, 85.0 * get_stats().territory_effect_strength, 0.06, 0.9)
				enemy.apply_slow(0.58, maxf(get_stats().active_duration_seconds, 1.2))
		&"active.magnet_short_pull":
			_magnet_field_remaining = maxf(_magnet_field_remaining, get_stats().active_duration_seconds)
			for enemy in _get_enemies_in_radius(get_stats().territory_effect_radius):
				enemy.receive_attack_hit(competitor_id, 5.0, 45.0, 0.04, 0.7)
				enemy.pull_toward(global_position, 180.0 * get_stats().territory_effect_strength)
		&"active.shield_burst":
			apply_guard(maxf(get_stats().active_duration_seconds, 1.1), 0.45)
			for enemy in _get_enemies_in_radius(get_stats().territory_effect_radius * 0.9):
				enemy.receive_attack_hit(competitor_id, 9.0, 155.0 * get_stats().territory_effect_strength, 0.08, 0.9)
		&"active.storm_wind_surge":
			_storm_field_remaining = maxf(_storm_field_remaining, get_stats().active_duration_seconds)
			for enemy in _get_enemies_in_radius(get_stats().territory_effect_radius * 1.05):
				enemy.receive_attack_hit(competitor_id, 8.0, 115.0, 0.08, 0.8)
				enemy.apply_storm_drift(global_position, 160.0 * get_stats().territory_effect_strength)
		_:
			return
	_active_cooldown_remaining = maxf(get_stats().active_cooldown_seconds, 0.4)
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.22)

func _maybe_fire_weapon() -> void:
	if _weapon_cooldown_remaining > 0.0:
		return
	var target := _find_nearest_enemy(get_weapon_range())
	if target == null:
		return

	var pressure_amount := _get_weapon_pressure_bonus() * match_config.weapon_pressure_bonus_scale
	match get_weapon_id():
		&"weapon.gun":
			target.receive_attack_hit(competitor_id, _get_weapon_damage(), _get_weapon_impact_force(), pressure_amount, _get_weapon_pressure_duration())
			apply_pressure_buff(pressure_amount * 0.5, 0.9)
		&"weapon.laser":
			target.receive_attack_hit(competitor_id, _get_weapon_damage(), _get_weapon_impact_force(), pressure_amount, _get_weapon_pressure_duration())
			target.apply_slow(_get_weapon_slow_multiplier(), _get_weapon_slow_duration())
			apply_focus_bonus(0.22 + _get_weapon_influence_bonus() * 0.2, 1.35)
		&"weapon.cannon":
			var impacted := _get_enemies_around_point(target.global_position, maxf(_get_weapon_splash_radius(), get_stats().body_radius * 2.2))
			if impacted.is_empty():
				impacted.append(target)
			for enemy in impacted:
				enemy.receive_attack_hit(competitor_id, _get_weapon_damage(), _get_weapon_impact_force(), pressure_amount, _get_weapon_pressure_duration())
			apply_pressure_buff(pressure_amount, _get_weapon_pressure_duration())
		&"weapon.magnet_device":
			var dragged := _get_enemies_around_point(target.global_position, maxf(_get_weapon_splash_radius(), 88.0))
			if dragged.is_empty():
				dragged.append(target)
			for enemy in dragged:
				enemy.receive_attack_hit(competitor_id, _get_weapon_damage(), 40.0, pressure_amount, _get_weapon_pressure_duration())
				enemy.pull_toward(global_position, _get_weapon_pull_force())
			_magnet_field_remaining = maxf(_magnet_field_remaining, 1.4)
			apply_focus_bonus(0.16, 1.0)
		&"weapon.shield_device":
			apply_guard(maxf(_get_weapon_guard_duration(), 1.1), maxf(_get_weapon_guard_strength(), 0.42))
			apply_focus_bonus(0.08 + _get_weapon_influence_bonus() * 0.15, 1.0)
			if target.global_position.distance_to(global_position) < get_stats().body_radius * 3.5:
				target.receive_attack_hit(competitor_id, _get_weapon_damage(), 30.0, pressure_amount * 0.5, 0.7)
		_:
			target.receive_attack_hit(competitor_id, _get_weapon_damage(), 120.0, pressure_amount, _get_weapon_pressure_duration())
	_weapon_cooldown_remaining = maxf(get_weapon_cooldown_seconds(), 0.25)
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.15)

func receive_attack_hit(attacker_id: int, damage: float, force: float, pressure_amount: float = 0.0, pressure_duration_seconds: float = 0.0) -> void:
	if _is_eliminated:
		return
	apply_impulse_from_position(attacker_id, force)
	apply_damage(attacker_id, damage)
	if pressure_amount > 0.0 and pressure_duration_seconds > 0.0:
		apply_pressure_debuff(pressure_amount, pressure_duration_seconds)

func apply_impulse_from_position(attacker_id: int, force: float) -> void:
	var source_position := global_position
	var attacker := _find_marble_by_id(attacker_id)
	if attacker != null:
		source_position = attacker.global_position
	apply_impulse_from(source_position, force)

func apply_impulse_from(source_position: Vector2, force: float) -> void:
	if _is_eliminated:
		return
	var direction := source_position.direction_to(global_position)
	if direction == Vector2.ZERO:
		direction = _random_direction()
	var mitigation := maxf(get_stats().knockback_resistance, 0.2)
	if _guard_remaining > 0.0:
		mitigation *= 1.0 + _guard_strength * 2.0
	velocity += direction * (force / (maxf(get_stats().mass, 0.3) * mitigation))
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.12)

func apply_damage(attacker_id: int, amount: float) -> void:
	if _is_eliminated or amount <= 0.0:
		return
	_last_attacker_id = attacker_id
	var effective_damage := amount / maxf(get_stats().defense_modifier, 0.2)
	_current_durability = maxf(_current_durability - effective_damage, 0.0)
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.18)
	if _current_durability <= 0.0:
		_eliminate()

func _eliminate() -> void:
	_is_eliminated = true
	_current_durability = 0.0
	velocity = Vector2.ZERO
	_respawn_remaining = match_config.respawn_delay_seconds if match_config != null else 0.0
	_reset_trail()
	eliminated.emit(_last_attacker_id, competitor_id)

func pull_toward(target_position: Vector2, force: float) -> void:
	if _is_eliminated:
		return
	var direction := global_position.direction_to(target_position)
	if direction == Vector2.ZERO:
		return
	var mitigation := maxf(get_stats().mass * maxf(get_stats().knockback_resistance, 0.4), 0.4)
	velocity += direction * (force / mitigation)
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.12)

func apply_storm_drift(source_position: Vector2, force: float) -> void:
	if _is_eliminated:
		return
	var direction := source_position.direction_to(global_position)
	if direction == Vector2.ZERO:
		direction = _random_direction()
	var tangent := direction.rotated(PI * 0.5 if _rng.randf() > 0.5 else -PI * 0.5)
	velocity += (direction * 0.55 + tangent * 0.8).normalized() * (force / maxf(get_stats().mass, 0.4))
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.12)

func apply_guard(duration_seconds: float, guard_strength: float) -> void:
	_guard_remaining = maxf(_guard_remaining, duration_seconds)
	_guard_strength = maxf(_guard_strength, guard_strength)
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.18)

func apply_slow(multiplier: float, duration_seconds: float) -> void:
	_slow_multiplier = minf(_slow_multiplier, clampf(multiplier, 0.3, 1.0))
	_slow_remaining = maxf(_slow_remaining, duration_seconds)
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.16)

func apply_pressure_debuff(amount: float, duration_seconds: float) -> void:
	var slow_cap := clampf(1.0 - amount, 0.62, 0.94)
	_slow_multiplier = minf(_slow_multiplier, slow_cap)
	_slow_remaining = maxf(_slow_remaining, duration_seconds * 0.7)
	_impact_flash_remaining = maxf(_impact_flash_remaining, 0.1)

func apply_pressure_buff(amount: float, duration_seconds: float) -> void:
	_pressure_bonus = maxf(_pressure_bonus, amount)
	_pressure_remaining = maxf(_pressure_remaining, duration_seconds)

func apply_focus_bonus(amount: float, duration_seconds: float) -> void:
	_focus_bonus = maxf(_focus_bonus, amount)
	_focus_remaining = maxf(_focus_remaining, duration_seconds)

func _update_navigation(delta: float) -> void:
	var stats := get_stats()
	var desired_direction := Vector2.ZERO
	var territory_point := _get_priority_navigation_point()
	var chase_target := _find_nearest_enemy(minf(get_weapon_range(), get_influence_radius() * 1.25))
	if territory_point != Vector2(INF, INF):
		_move_target = territory_point
		desired_direction = global_position.direction_to(_move_target)
		if chase_target != null and _prefer_enemy_pressure_over_pathing():
			desired_direction = (desired_direction * 0.45 + global_position.direction_to(chase_target.global_position) * 0.9).normalized()
	elif chase_target != null:
		desired_direction = global_position.direction_to(chase_target.global_position)
		_move_target = chase_target.global_position
	elif global_position.distance_to(_move_target) <= stats.body_radius * 1.5:
		_move_target = _random_point_in_bounds()
		desired_direction = global_position.direction_to(_move_target)
	elif _rng.randf() < delta * 0.14:
		_move_target = _random_point_in_bounds()
		desired_direction = global_position.direction_to(_move_target)
	else:
		desired_direction = global_position.direction_to(_move_target)

	var center := arena_bounds.get_center()
	var distance_to_center := global_position.distance_to(center)
	var max_center_distance := minf(arena_bounds.size.x, arena_bounds.size.y) * 0.35
	if distance_to_center > max_center_distance:
		desired_direction = (desired_direction + global_position.direction_to(center) * 1.35).normalized()

	var speed_multiplier := 1.0
	if _overheat_remaining > 0.0:
		speed_multiplier *= 1.22
	if _slow_remaining > 0.0:
		speed_multiplier *= _slow_multiplier
	if _guard_remaining > 0.0 and get_passive_slot_id() == &"passive.shield_knockback_guard":
		speed_multiplier *= 0.93
	if _magnet_field_remaining > 0.0:
		speed_multiplier *= 1.04
	var desired_velocity := desired_direction * stats.move_speed * speed_multiplier
	velocity = velocity.move_toward(desired_velocity, stats.acceleration * delta)
	if desired_direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, stats.friction * delta)

func _prefer_enemy_pressure_over_pathing() -> bool:
	var profile := get_ai_role_profile()
	return profile == &"aggressive" or profile == &"chaos"

func _get_priority_navigation_point() -> Vector2:
	var territory := _get_territory_controller()
	if territory == null:
		return Vector2(INF, INF)
	return territory.get_priority_point_for_actor(self, global_position)

func _get_territory_controller() -> TerritoryController:
	var nodes := get_tree().get_nodes_in_group(GameConstants.GROUP_TERRITORY)
	for node in nodes:
		if node is TerritoryController:
			return node as TerritoryController
	return null

func _handle_slide_collisions() -> void:
	if _bounce_cooldown_seconds > 0.0:
		return

	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		if collision == null:
			continue
		var collider := collision.get_collider()
		velocity = velocity.bounce(collision.get_normal()) * 0.92
		_move_target = _random_point_in_bounds()
		_bounce_cooldown_seconds = 0.12
		if collider is MarbleActor:
			_apply_collision_passive(collider as MarbleActor)
		break

func _apply_collision_passive(other: MarbleActor) -> void:
	if other == null or other.competitor_id == competitor_id or other.is_eliminated():
		return
	other.receive_attack_hit(competitor_id, match_config.collision_damage, get_stats().collision_force * 95.0, match_config.collision_pressure_bonus, 0.8)
	match get_passive_slot_id():
		&"passive.fire_burn":
			other.apply_pressure_debuff(0.12, 1.4)
		&"passive.ice_first_hit_slow":
			other.apply_slow(0.72, 1.2)
		&"passive.magnet_pickup_pull":
			other.pull_toward(global_position, 70.0)
			apply_focus_bonus(0.08, 0.9)
		&"passive.shield_knockback_guard":
			apply_guard(0.9, 0.35)
		&"passive.storm_deflect":
			other.apply_storm_drift(global_position, 115.0)

func _find_nearest_enemy(max_distance: float) -> MarbleActor:
	var best_enemy: MarbleActor = null
	var best_distance := max_distance
	for node in get_tree().get_nodes_in_group(GameConstants.GROUP_MARBLE):
		if not (node is MarbleActor):
			continue
		var marble := node as MarbleActor
		if marble == self or marble.competitor_id == competitor_id:
			continue
		if not marble.is_available_for_territory():
			continue
		var distance := global_position.distance_to(marble.global_position)
		if distance > max_distance:
			continue
		if best_enemy == null or distance < best_distance:
			best_enemy = marble
			best_distance = distance
	return best_enemy

func _find_marble_by_id(target_competitor_id: int) -> MarbleActor:
	for node in get_tree().get_nodes_in_group(GameConstants.GROUP_MARBLE):
		if node is MarbleActor and (node as MarbleActor).competitor_id == target_competitor_id:
			return node as MarbleActor
	return null

func _get_enemies_in_radius(radius: float) -> Array[MarbleActor]:
	return _get_enemies_around_point(global_position, radius)

func _get_enemies_around_point(point: Vector2, radius: float) -> Array[MarbleActor]:
	var enemies: Array[MarbleActor] = []
	for node in get_tree().get_nodes_in_group(GameConstants.GROUP_MARBLE):
		if not (node is MarbleActor):
			continue
		var marble := node as MarbleActor
		if marble == self or marble.competitor_id == competitor_id:
			continue
		if not marble.is_available_for_territory():
			continue
		if point.distance_to(marble.global_position) <= radius:
			enemies.append(marble)
	return enemies

func _get_weapon_damage() -> float:
	if weapon_definition == null:
		return 14.0
	return weapon_definition.damage

func _get_weapon_impact_force() -> float:
	if weapon_definition == null:
		return 140.0
	return weapon_definition.impact_force

func _get_weapon_splash_radius() -> float:
	if weapon_definition == null:
		return 0.0
	return weapon_definition.splash_radius

func _get_weapon_pressure_bonus() -> float:
	if weapon_definition == null:
		return 0.14
	return weapon_definition.pressure_bonus

func _get_weapon_pressure_duration() -> float:
	if weapon_definition == null:
		return 1.0
	return weapon_definition.pressure_duration_seconds

func _get_weapon_slow_duration() -> float:
	if weapon_definition == null:
		return 0.0
	return weapon_definition.slow_duration_seconds

func _get_weapon_slow_multiplier() -> float:
	if weapon_definition == null:
		return 0.82
	return weapon_definition.slow_multiplier

func _get_weapon_pull_force() -> float:
	if weapon_definition == null:
		return 110.0
	return weapon_definition.pull_force

func _get_weapon_guard_duration() -> float:
	if weapon_definition == null:
		return 0.0
	return weapon_definition.guard_duration_seconds

func _get_weapon_guard_strength() -> float:
	if weapon_definition == null:
		return 0.0
	return weapon_definition.guard_strength

func _get_weapon_influence_bonus() -> float:
	if weapon_definition == null:
		return 0.0
	return weapon_definition.influence_bonus

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
	while _trail_points.size() > TRAIL_POINT_COUNT:
		_trail_points.pop_front()

func _reset_trail() -> void:
	_trail_points.clear()
	_trail_points.append(global_position)
