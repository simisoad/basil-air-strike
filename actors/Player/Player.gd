class_name Player extends Node2D

signal player_falled_signal(player_pos: Vector2)
signal player_died_signal

@export_group("Player Stats")
@export var stats_template: PlayerStats

@export_group("Player Ragdoll (not yet implemented!)")
@export var ragdoll_physics_scene: PackedScene
@export var board_physics_scene: PackedScene

# Components
@onready var trick_component: PlayerTrickComponent = %TrickComponent
@onready var movement_component: PlayerMovementComponent = %MovementComponent
@onready var sound_component: SoundComponent = %SoundComponent
@onready var damage_component: PlayerDamageComponet = %DamageComponent
@onready var ground_detector_component: PlayerGroundDetectorComponent = %GroundDetectorComponent
@onready var health_component: PlayerHealthComponent = %HealthComponent
@onready var level_succsess_component: PlayerLevelSuccsessComponent = %LevelSuccsessComponent


# Physics Componets
@onready var skating_physics: RigidBody2D = $SkatingPhysics
@onready var can_jump_ray: RayCast2D = %CanJumpRay
@onready var on_ground_ray_front: RayCast2D = %OnGroundRayFront
@onready var on_ground_ray_rear: RayCast2D = %OnGroundRayRear

@onready var center_of_mass_position: Marker2D = %CenterOfMassPosition

var runtime_stats: PlayerStats
var active_physics_body: RigidBody2D

var is_in_air: bool = false

func initialize(player_state: PlayerStats):
	runtime_stats = player_state
	_physics_setup()
	_components_setup()
	_broadcast_initial_state()

func _physics_setup() -> void:
	active_physics_body = skating_physics
	active_physics_body.center_of_mass = center_of_mass_position.position

func _broadcast_initial_state() -> void:
	_on_score_updated(runtime_stats.current_score)
	_on_player_hit(runtime_stats.health)

func _components_setup() -> void:
	# Movement:
	movement_component.physics_body = active_physics_body
	movement_component.stats = runtime_stats
	# Trick:
	trick_component.physics_body = active_physics_body
	trick_component.stats = runtime_stats
	trick_component.lifes_added.connect(sound_component.play_health_added_sound)
	trick_component.score_updated.connect(_on_score_updated)
	# Sound:
	sound_component.physics_body = active_physics_body
	# Damage:
	damage_component.physics_body = active_physics_body
	damage_component.stats = runtime_stats
	damage_component.was_hit.connect(sound_component.play_skater_hurt_sound)
	damage_component.was_hit.connect(health_component.take_damage)
	damage_component.fell_down.connect(sound_component.play_skater_hurt_sound)
	damage_component.fell_down.connect(health_component.take_damage)
	damage_component.stand_up_attempted.connect(_stand_up)
	# Health:
	health_component.stats = runtime_stats
	health_component.player_died.connect(_on_player_died)
	health_component.player_hit.connect(_on_player_hit)
	# Level Success
	level_succsess_component.next_level_reached.connect(_on_next_level_reached)

func _physics_process(delta: float) -> void:
	_player_inputs(delta)
	_check_ground_air()
	# TODO: is this Clean-Code?
	sound_component.play_skater_rolling_sound(is_in_air)
	# TODO: Refactoring (do not use Autoloads)
	EventBus.player_moved.emit(active_physics_body.global_position)
	damage_component.is_on_ground = !is_in_air

func _check_ground_air() -> void:
	if ground_detector_component.is_on_ground():
		if is_in_air:
			_on_landed()
		is_in_air = false
	else:
		is_in_air = true

func _player_inputs(delta: float) -> void:
	if not is_in_air:
		var move_direction: float = Input.get_axis("Move_Left", "Move_Right")
		movement_component.handle_ground_movement(move_direction)
		if Input.is_action_just_pressed("Break"):
			movement_component.handle_breaking()
	else:
		trick_component.track_rotation(delta)
	var torque_dir = Input.get_axis("Torque_Left", "Torque_Right")
	movement_component.handle_torque_control(torque_dir, delta)
	if Input.is_action_just_pressed("Jump"):
		if ground_detector_component.can_jump():
			movement_component.handle_jump(torque_dir)
			damage_component.recovered_from_fall_without_help()
		else:
			damage_component.stand_up_initiate()

func _on_landed() -> void:
	sound_component.play_skater_landing_sound()
	trick_component.set_score()

func _stand_up() -> void:
	player_falled_signal.emit(active_physics_body.global_position)

func _on_player_died() -> void:
	player_died_signal.emit()

func _on_score_updated(new_score) -> void:
	EventBus.player_score_updated.emit(new_score)

func _on_player_hit(damage: int) -> void:
	EventBus.player_hit.emit(damage)

func _on_next_level_reached(next_level: String) -> void:
	EventBus.next_level_reached.emit(next_level)
