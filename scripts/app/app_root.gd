extends Node

class_name AppRoot

const PRESET_CONFIG_PATHS := {
	"1vai": "res://resources/config/playtests/match_config_1vAI.tres",
	"multi_ai": "res://resources/config/playtests/match_config_multi_AI.tres",
	"full_ai": "res://resources/config/playtests/match_config_full_AI_simulation.tres",
}

@export var world_scene: PackedScene
@export var match_config: MatchConfig

var _world_instance: PrototypeWorld

func _ready() -> void:
	match_config = _resolve_boot_config(match_config)
	_spawn_world()

func _spawn_world() -> void:
	if world_scene == null:
		push_error("AppRoot requires a world_scene to boot the prototype.")
		return

	if is_instance_valid(_world_instance):
		_world_instance.queue_free()

	var spawned_world := world_scene.instantiate()
	if not (spawned_world is PrototypeWorld):
		push_error("AppRoot expected world_scene to instantiate PrototypeWorld.")
		spawned_world.queue_free()
		return

	_world_instance = spawned_world
	_world_instance.match_config = match_config
	add_child(_world_instance)
	_world_instance.initialize(match_config)

func _resolve_boot_config(default_config: MatchConfig) -> MatchConfig:
	var args := OS.get_cmdline_user_args()
	for index in range(args.size()):
		if args[index] != "--test-preset":
			continue
		if index + 1 >= args.size():
			break
		var preset_key := String(args[index + 1]).to_lower()
		if not PRESET_CONFIG_PATHS.has(preset_key):
			push_warning("Unknown playtest preset '%s'. Using default match_config." % preset_key)
			return default_config
		var loaded := load(PRESET_CONFIG_PATHS[preset_key])
		if loaded is MatchConfig:
			return loaded as MatchConfig
		push_warning("Could not load playtest preset '%s'. Using default match_config." % preset_key)
		return default_config
	return default_config
