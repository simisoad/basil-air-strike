class_name StructurePolygon extends Polygon2D

@onready var collision_polygon_2d: CollisionPolygon2D = CollisionPolygon2D.new()
@onready var particle_occluder: LightOccluder2D = LightOccluder2D.new()
@onready var occluder2D: OccluderPolygon2D = OccluderPolygon2D.new()
@onready var static_body: StaticBody2D = StaticBody2D.new()

func _ready() -> void:
	_set_collision()
	_structure_setup()


func _set_collision()-> void:
	collision_polygon_2d.polygon = polygon
	occluder2D.polygon = polygon
	particle_occluder.occluder = occluder2D


func _structure_setup()->void:
	add_child(static_body)
	static_body.add_child(collision_polygon_2d)
	static_body.add_child(particle_occluder)
