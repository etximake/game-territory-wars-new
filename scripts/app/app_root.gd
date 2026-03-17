extends Node

class_name AppRoot

@export var world_scene: PackedScene
@export var match_config: MatchConfig

var _world_instance: PrototypeWorld

func _ready() -> void:
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
	add_child(_world_instance)
	_world_instance.initialize(match_config)
