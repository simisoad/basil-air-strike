class_name Skater extends RigidBody2D

@export_group("Movement on Floor")
@export var move_force: float = 800.0
@export var max_speed: float = 800.0

@export_group("Jump Settings")
@export var jump_force: float = 600.0
@export var jump_force_x: float = 50.0

@export_group("Torque Control")
@export var control_torque: float = 1000000.0 #hmm, ja so gehts

@export_group("Player Health")
@export var fall_damage: int = 1
@export var pot_damage: int = 5
@export var standup_time: float = 1.0
@export var was_hit_time: float = 0.5
@export_group("Player scoring")
@export var score_tolerance: int = 20
@export var scores: Dictionary = {
		"180": 250,
		"270": 500,
		"360": 1000,
		"450": 1500,
		"720": 3000,
}

@onready var skateboard_shape: CollisionShape2D = %CollisionShapeSkateboard
@onready var can_jump_ray: RayCast2D = %CanJumpRay
@onready var on_ground_ray_front: RayCast2D = %OnGroundRayFront
@onready var on_ground_ray_rear: RayCast2D = %OnGroundRayRear
@onready var stand_up_timer: Timer = %StandUpTimer
@onready var was_hit_timer: Timer = $WasHitTimer

var is_falled: bool = false

var reached_rotation_array: Array = []
var reached_rotation_index: int = -1
var was_in_air: bool = false
var total_rotation_in_air: float = 0.0

var debug_movement_force_pos: Vector2
var debug_movement_force: Vector2

var debug_jump_force_pos: Vector2
var debug_jump_force: Vector2

var was_hit: bool = false

func _ready() -> void:
	self.center_of_mass = %CenterOfMass.position
	_setup_reached_rotation_array()

func _setup_reached_rotation_array() -> void:
	for rot: String in self.scores.keys():
		self.reached_rotation_array.append(deg_to_rad(rot.to_int()-self.score_tolerance))
	print(self.reached_rotation_array)

func _physics_process(delta: float) -> void:
	_player_inputs(delta)

	#send the global_position for enemys
	GameManager.player_moved_signal.emit(self.global_position)
	SoundManager.play_skater_rolling_sound(self)

func _player_inputs(delta: float) -> void:
	if _is_on_ground():
		if self.was_in_air:
			_on_landed()
		self.was_in_air = false
		_handle_ground_movement()
		if Input.is_action_just_pressed("Break"):
			_break()
	else:
		_track_rotation(delta)
		self.was_in_air = true
	var torque_dir = Input.get_axis("Torque_Left", "Torque_Right")
	_handle_torque_control(torque_dir, delta)

	if Input.is_action_just_pressed("Jump") and _can_jump():
		_perform_jump(torque_dir)

# Funktion für die Bewegung am Boden
func _handle_ground_movement() -> void:
	var move_direction: float = Input.get_axis("Move_Left", "Move_Right")
	if abs(self.linear_velocity.x) < self.max_speed or \
			(sign(self.linear_velocity.x) != move_direction \
			and move_direction != 0):
		var force_position = self.skateboard_shape.global_position-self.global_position
		var dir_vector: Vector2 = Vector2(move_direction * self.move_force * self.mass, 0)
		self.debug_movement_force_pos = force_position
		self.debug_movement_force = dir_vector
		queue_redraw()
		apply_force(dir_vector, force_position)

func _break() -> void:
	#krass schlechte brems-methode :)
	self.linear_velocity = Vector2.ZERO

func _handle_torque_control(direction: float, delta: float) -> void:
	var torque = direction * self.control_torque * self.mass * delta
	apply_torque(torque)

func _perform_jump(p_direction: float) -> void:
	SoundManager.play_skater_jump_sound()
	var jump_vec: Vector2 = Vector2(
			p_direction * self.jump_force_x * self.mass,
			-self.jump_force * self.mass
			)
	var force_position = self.skateboard_shape.global_position-self.global_position
	self.debug_jump_force_pos = self.center_of_mass
	self.debug_jump_force = to_global(jump_vec)

	apply_impulse(to_global(jump_vec))
	queue_redraw()


func _track_rotation(p_delta: float) -> void:
	self.total_rotation_in_air += self.angular_velocity * p_delta
	if self.reached_rotation_index >= self.reached_rotation_array.size()-1:
		return
	if abs(self.total_rotation_in_air) >= self.reached_rotation_array[self.reached_rotation_index+1]:
		self.reached_rotation_index += 1

func _on_landed() -> void:
	SoundManager.play_skater_landing_sound()
	_set_score()

func _set_score() -> void:
	if self.reached_rotation_index == -1:
		return
	print("Rot: ", reached_rotation_array[reached_rotation_index])
	var degrees: float = rad_to_deg(self.reached_rotation_array[reached_rotation_index])
	var score_to_add: int = 0
	for score: String in self.scores.keys():
		if abs(degrees) >= score.to_int() - self.score_tolerance:
			score_to_add = self.scores[score]
	GameManager.score_add_signal.emit(score_to_add)
	self.total_rotation_in_air = 0.0
	self.reached_rotation_index = -1

func _is_on_ground() -> bool:
	if self.on_ground_ray_front.is_colliding() or self.on_ground_ray_rear.is_colliding():
		return true
	return false

func _can_jump() -> bool:
	return self.can_jump_ray.is_colliding()

func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, local_shape_index: int) -> void:
	# evtl. nicht so optimales SRP?

	if body.is_in_group("Projectiles") and not was_hit:
		was_hit = true
		self.was_hit_timer.start(was_hit_time)
		SoundManager.play_skater_hurt_sound()
		GameManager.on_player_hit(pot_damage)
		return
	var shape_owner: Node2D = shape_owner_get_owner(local_shape_index)

	if shape_owner.is_in_group("HurtPlayer") and\
			not self.is_falled and not _is_on_ground():
		self.is_falled = true
		call_deferred("_player_falled")


func _player_falled() -> void:
	SoundManager.play_skater_hurt_sound()
	GameManager.on_player_hit(self.fall_damage)
	self.stand_up_timer.start(self.standup_time)

func _on_stand_up_timer_timeout() -> void:
	self.stand_up_timer.stop()
	if not self._is_on_ground():
		GameManager.player_falled_signal.emit(self.global_position)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is LevelSuccess:
		#hmm, ok, if it is an LevelSuccess it must be in this group:
		if area.is_in_group("LevelSuccess"):
			var level_sc: LevelSuccess = area
			await self.get_tree().create_timer(1.0).timeout
			GameManager.next_level_signal.emit(level_sc.next_level)


func _draw() -> void:
	draw_line(self.debug_movement_force_pos, self.debug_movement_force, Color.AQUA, 1.0)
	draw_line(self.debug_jump_force_pos, self.debug_jump_force, Color.RED, 1.0)


func _on_was_hit_timer_timeout() -> void:
	self.was_hit = false
