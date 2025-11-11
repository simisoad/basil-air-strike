class_name LevelDatabase extends Resource

const SAVE_PATH = "user://progress.cfg"

@export var _all_levels: Dictionary = {
	"tutorial": "res://Levels/level00.tscn",
	"level01": "res://Levels/level01.tscn",
	"level02": "res://Levels/level02.tscn",
}

var _level_order: Array[String] = []
var start_level_key: String = ""

func _ready() -> void:
	_set_level_order()

func _set_level_order()-> void:
	for level in _all_levels:
		_level_order.append(level)

func get_level(level: String) -> String:
	if not _all_levels.has(level):
		push_error("Level: %s, does not exist!" % level)
		return "" #hmm? Error-handling? ok, das mache ich wenn ich get_level aufrufe.
	return _all_levels[level]

func load_highest_level() -> String:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return _level_order[0]

	var highest_level = config.get_value("progress", "highest_level", _level_order[0])
	return highest_level

func update_and_save_progress(newly_unlocked_level: String):
	var current_highest_level = load_highest_level()

	var new_level_index = _level_order.find(newly_unlocked_level)
	var current_highest_index = _level_order.find(current_highest_level)

	if new_level_index > current_highest_index:
		var config = ConfigFile.new()
		config.set_value("progress", "highest_level", newly_unlocked_level)
		config.save(SAVE_PATH)

func get_first_level() -> String:
	return _level_order[0]

func get_all_levels() -> Array[String]:
	return _level_order
