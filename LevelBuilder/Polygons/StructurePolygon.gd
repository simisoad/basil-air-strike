class_name StructurePolygon extends Polygon2D

@onready var collision_polygon_2d: CollisionPolygon2D = CollisionPolygon2D.new()
@onready var static_body: StaticBody2D = StaticBody2D.new()

func _ready() -> void:
	_set_collision()
	_structure_setup()
	
	
func _set_collision()-> void:
	self.collision_polygon_2d.polygon = self.polygon

func _structure_setup()->void:
	self.add_child(self.static_body)
	self.static_body.add_child(self.collision_polygon_2d)
