extends Polygon2D

@onready var collision_polygon_2d: CollisionPolygon2D = %CollisionPolygon2D

func _ready() -> void:
	collision_polygon_2d.polygon = self.polygon
