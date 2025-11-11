class_name PlayerLevelSuccsessComponent extends Node2D

signal next_level_reached(next_level: String)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is LevelSuccess:
		if area.is_in_group("LevelSuccess"):
			var level_sc: LevelSuccess = area
			await get_tree().create_timer(1.0).timeout
			next_level_reached.emit(level_sc.next_level)
