class_name WorldLevelLoaderComponent extends Node

@export var current_level: BaseLevel

@onready var current_level_container: Node2D = %CurrentLevelContainer
var level_database: LevelDatabase

var player_start_transform: Transform2D

func load_level(next_level: String )-> BaseLevel:
	_check_has_current_level()
	await self.get_tree().process_frame
	var load_path: String = level_database.get_level(next_level)
	if not load_path:
		push_error("Level: %s was not found in LevelManager!" % next_level)
		#Fallback:
		load_path = level_database.get_level(level_database.get_first_level())

	var level_packed: PackedScene = load(load_path)
	current_level = level_packed.instantiate() as BaseLevel
	current_level_container.add_child(current_level)
	await self.get_tree().process_frame
	# TODO: player_start_transform really necessary here:
#	player_start_transform = current_level.player_start.global_transform
	return current_level

func _check_has_current_level()->void:
	if current_level_container.get_child_count() > 0:
		var childs: Array = current_level_container.get_children()
		for child: Node in childs:
			child.queue_free()
