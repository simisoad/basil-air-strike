class_name Skater extends RigidBody2D


@export_group("Movement on Floor")
@export var move_force: float = 800.0
@export var max_speed: float = 800.0

@export_group("Jump Settings")
@export var jump_force: float = 600.0
@export var jump_force_x: float = 50.0

@export_group("Torque Control")
@export var control_torque: float = 1000000.0 #hmm, ja so gehts

@onready var skateboard_shape: CollisionShape2D = %CollisionShapeSkateboard 
@onready var can_jump_ray: RayCast2D = %CanJumpRay
@onready var on_ground_ray_front: RayCast2D = %OnGroundRayFront
@onready var on_ground_ray_rear: RayCast2D = %OnGroundRayRear

@export_group("Player Health")
@export var fall_damage: int = 1
@export var pot_damage: int = 1

@export_group("Player scoring")
@export var score_360: int = 1000

var player_was_in_air: bool = false
var total_rotation_in_air: float = 0.0



func _physics_process(delta: float) -> void:
	_player_inputs(delta)
	#send the global_position for enemys
	GameManager.player_moved_signal.emit(self.global_position)
	SoundManager.play_skater_rolling_sound(self)
	


func _player_inputs(delta: float) -> void:
	
	if _is_on_ground():
		if self.player_was_in_air:
			_on_landed()
		self.player_was_in_air = false
		_handle_ground_movement()
		if Input.is_action_just_pressed("Break"):
			_break()
	else:
		_track_rotation(delta)
		self.player_was_in_air = true
	var torque_dir = Input.get_axis("Torque_Left", "Torque_Right")
	_handle_torque_control(torque_dir, delta)

	if Input.is_action_just_pressed("Jump") and _can_jump():
		_perform_jump(torque_dir)

# Funktion für die Bewegung am Boden
func _handle_ground_movement() -> void:
	var move_direction = Input.get_axis("Move_Left", "Move_Right")
	if abs(self.linear_velocity.x) < self.max_speed or \
			(sign(self.linear_velocity.x) != move_direction \
			and move_direction != 0):
		var force_position = self.skateboard_shape.position
		apply_force(Vector2(move_direction * self.move_force * self.mass, 0), force_position)

func _break() -> void:
	#krass schlechte brems-methode :)
	self.linear_velocity = Vector2.ZERO

func _handle_torque_control(direction: float, delta: float) -> void:
	var torque = direction * self.control_torque * self.mass * delta
	apply_torque(torque)

func _perform_jump(p_direction: float) -> void:
	SoundManager.play_skater_jump_sound()
	self.linear_velocity.y = 0
	apply_central_impulse(Vector2(
			p_direction * self.jump_force_x * self.mass, 
			-self.jump_force * self.mass
			))
			
func _track_rotation(p_delta: float) -> void:
	self.total_rotation_in_air += self.angular_velocity * p_delta
	
func _on_landed() -> void:
	SoundManager.play_skater_landing_sound()
	var degrees = rad_to_deg(self.total_rotation_in_air)
	if abs(degrees) >= 350: # Ein bisschen Toleranz
		GameManager.score_add_signal.emit(self.score_360)
	self.total_rotation_in_air = 0.0

func _is_on_ground() -> bool:
	if self.on_ground_ray_front.is_colliding() or self.on_ground_ray_rear.is_colliding():
		return true
	return false
	
func _can_jump() -> bool:
	return self.can_jump_ray.is_colliding()

func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, local_shape_index: int) -> void:
	# evtl. nicht so optimales SRP?
	
	if body.is_in_group("Projectiles"):
		SoundManager.play_skater_hurt_sound()
		GameManager.on_player_hit(pot_damage)
		return
	var shape_owner: Node2D = shape_owner_get_owner(local_shape_index)

	if shape_owner.is_in_group("HurtPlayer"):
		SoundManager.play_skater_hurt_sound()
		call_deferred("_player_falled")
		GameManager.on_player_hit(self.fall_damage)
		
func _player_falled() -> void:
	GameManager.player_falled_signal.emit(self.global_position)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is LevelSuccess:
		#hmm, ok, if it is an LevelSuccess it must be in this group:
		if area.is_in_group("LevelSuccess"):
			var level_sc: LevelSuccess = area
			GameManager.next_level_signal.emit(level_sc.next_level)
				
