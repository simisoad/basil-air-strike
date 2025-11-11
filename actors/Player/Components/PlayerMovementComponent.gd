class_name PlayerMovementComponent extends Node2D

@export var stats: PlayerStats

var physics_body: RigidBody2D

func _ready() -> void:
	await self.get_tree().process_frame
	if not _validate_dependencies():
		push_error("PlayerMovementComponent won't work (correctly) due to missing dependencies.")
		return

func handle_ground_movement(move_direction: float) -> void:
	if abs(physics_body.linear_velocity.x) < stats.max_speed or \
			(sign(physics_body.linear_velocity.x) != move_direction \
			and move_direction != 0):
		var force_position = %ApplyForcePosition.global_position - physics_body.global_position
		var dir_vector: Vector2 = Vector2(move_direction * stats.move_force * physics_body.mass, 0)
		physics_body.apply_force(dir_vector, force_position)

func handle_breaking() -> void:
	# TODO: better break method
	physics_body.linear_velocity = Vector2.ZERO

func handle_torque_control(direction: float, _delta: float) -> void:
	var torque = direction * stats.control_torque * physics_body.mass * _delta
	physics_body.apply_torque(torque)

func handle_jump(direction: float) -> void:
	#SoundManager.play_skater_jump_sound()
	var jump_vec: Vector2 = Vector2(
			direction * stats.jump_force * physics_body.mass,
			-stats.jump_force * physics_body.mass
			)

	#var force_position = apply_force_position.global_position-physics_body.global_position
	physics_body.apply_impulse(to_global(jump_vec))

func _validate_dependencies() -> bool:
	var is_valid: bool = true

	if not physics_body:
		push_error("Dependency missing: ‘physics_body’ was not assigned.")
		is_valid = false

	if not stats:
		push_error("Dependency missing: ‘stats’ was not assigned.")
		is_valid = false

	return is_valid
