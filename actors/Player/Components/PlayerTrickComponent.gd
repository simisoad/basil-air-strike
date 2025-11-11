class_name PlayerTrickComponent extends Node2D

signal score_updated(current_score)
signal lifes_added
@export var stats: PlayerStats
# Public:
var physics_body: RigidBody2D
# Private:
var _reached_rotation_array: Array = []
var _reached_rotation_index: int = -1
var _total_rotation_in_air: float = 0.0

func _ready() -> void:
	await self.get_tree().process_frame
	if not _validate_dependencies():
		push_error("PlayerTrickComponent won't work (correctly) due to missing dependencies.")
		return
	_setup_reached_rotation_array()

func track_rotation(delta: float) -> void:
	_total_rotation_in_air += physics_body.angular_velocity * delta
	if _reached_rotation_index >= _reached_rotation_array.size()-1:
		return
	if abs(_total_rotation_in_air) >= _reached_rotation_array[_reached_rotation_index+1]:
		_reached_rotation_index += 1

func set_score() -> void:
	if _reached_rotation_index == -1:
		return
	print("Rot: ", _reached_rotation_array[_reached_rotation_index])
	var degrees: float = rad_to_deg(_reached_rotation_array[_reached_rotation_index])
	var score_to_add: int = 0
	for score: String in stats.scores.keys():
		if abs(degrees) >= score.to_int() - stats.score_tolerance:
			score_to_add = stats.scores[score]
	_total_rotation_in_air = 0.0
	_reached_rotation_index = -1
	_score_update(score_to_add)

func _setup_reached_rotation_array() -> void:
	for rot: String in stats.scores.keys():
		_reached_rotation_array.append(deg_to_rad(rot.to_int()-stats.score_tolerance))

func _score_update(score_to_add: int) -> void:
	stats.current_score += score_to_add
	if stats.current_score >= stats.add_life_for_score:
		lifes_added.emit()
		stats.current_score -= stats.add_life_for_score
		stats.health += stats.lifes_for_score
	score_updated.emit(stats.current_score)

func _validate_dependencies() -> bool:
	var is_valid: bool = true

	if not physics_body:
		push_error("Dependency missing: ‘physics_body’ was not assigned.")
		is_valid = false

	if not stats:
		push_error("Dependency missing: ‘stats’ was not assigned.")
		is_valid = false

	return is_valid
