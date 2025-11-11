class_name PlayerDamageComponet extends Node2D

signal was_hit(damage_amount)
signal fell_down(damage_amount)
signal stand_up_attempted


@onready var _stand_up_timer: Timer = %StandUpTimer
@onready var _invincible_timer: Timer = %InvincibleTimer

@export var stats: PlayerStats

# Public:
var physics_body: RigidBody2D
var is_on_ground: bool = true

# Private:
var _already_hit: bool = false
var _is_player_falled: bool = false

func _ready() -> void:
	await self.get_tree().process_frame
	if not _validate_dependencies():
		push_error("PlayerDamageComponent won't work (correctly) due to missing dependencies.")
		return
	physics_body.body_shape_entered.connect(_on_body_shape_entered)

func recovered_from_fall_without_help() -> void:
	if _is_player_falled:
		_is_player_falled = false

func stand_up_initiate() -> void:
	if _is_player_falled:
		print("Player should stand up")
		_stand_up_timer.start(stats.standup_time)
		_is_player_falled = false
		return
	print("Player is alreay standing")


func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Projectiles") and not _already_hit:
		_already_hit = true
		call_deferred("_player_hit")
		return
	var shape_owner: Node2D = physics_body.shape_owner_get_owner(local_shape_index)
	if shape_owner.is_in_group("HurtPlayer") and\
			not _is_player_falled and not is_on_ground:
		# BUG: What happens if the player falls down and gets back up without using the stand_up_initiate() method?
		_is_player_falled = true
		call_deferred("_player_falled")

func _player_hit() -> void:
		_invincible_timer.start(stats.invincible_time)
		was_hit.emit(stats.pot_damage)


func _player_falled() -> void:
	fell_down.emit(stats.fall_damage)

func _stand_up() -> void:
	_stand_up_timer.stop()
	stand_up_attempted.emit()

func _became_vulnerable() -> void:
	_already_hit = false

func _validate_dependencies() -> bool:
	var is_valid: bool = true

	if not physics_body:
		push_error("Dependency missing: ‘physics_body’ was not assigned.")
		is_valid = false

	if not stats:
		push_error("Dependency missing: ‘stats’ was not assigned.")
		is_valid = false

	return is_valid
