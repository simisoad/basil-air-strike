class_name LevelSuccess extends Area2D

@export var next_level: String
@export var collision_polygon_2D: CollisionPolygon2D

func _ready() -> void:
	if not self.next_level:
		push_error("Level_Success 'next_level' in Level %s is empty" % self.get_parent().name)
	if self.collision_polygon_2D == null:
		push_error("Level_Success 'next_level' in Level %s has none collision!" % self.get_parent().name)
