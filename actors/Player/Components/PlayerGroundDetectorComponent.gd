class_name PlayerGroundDetectorComponent extends Node2D

@onready var on_ground_ray_front: RayCast2D = %OnGroundRayFront
@onready var on_ground_ray_rear: RayCast2D = %OnGroundRayRear
@onready var can_jump_ray: RayCast2D = %CanJumpRay

func is_on_ground() -> bool:
	return on_ground_ray_front.is_colliding() or on_ground_ray_rear.is_colliding()

func can_jump() -> bool:
	return can_jump_ray.is_colliding()
