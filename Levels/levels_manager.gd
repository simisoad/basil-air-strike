class_name LevelManager extends Node2D

@onready var _all_levels: Dictionary = {
	"tutorial": "res://Levels/level00.tscn",
	"level01": "res://Levels/level01.tscn",
}

func get_level(p_level: String) -> String:
	if not self._all_levels.has(p_level):
		push_error("Level: %s, does not exist!" % p_level)
		return "" #hmm? Error-handling?
	return self._all_levels[p_level]
