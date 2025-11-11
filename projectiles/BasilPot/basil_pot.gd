class_name BasilPot extends RigidBody2D

@export var explosion_effect_packed: PackedScene
@export var pot_shattering_sound: AudioStreamRandomizer

func _ready() -> void:
	if not _validate_dependencies():
		push_error("BasilPot won't work (correctly) due to missing dependencies!")
		# REVIEW: Should this object self-destruct in this case?
		self.queue_free()

func launch(target_position: Vector2, impulse_strength: float) -> void:
	# TODO: Think about target logic. (The normal idea does not really work.)
	var direction: Vector2 = global_position.direction_to(target_position)
	#var dir_normal: Vector2 = Vector2(-direction.y, direction.x)
	var target_vector: Vector2 = direction * impulse_strength
	#var normal_vector: Vector2 = dir_normal * 200
	apply_impulse(target_vector)


func _on_body_entered(_body: Node) -> void:
	var shatter_sound: ShatterSound = ShatterSound.new(pot_shattering_sound)
	EventBus.object_shattered.emit(
			global_position,
			explosion_effect_packed,
			shatter_sound,
			)
	self.queue_free()


func _on_selfdestruct_timer_timeout() -> void:
	self.queue_free()

func _validate_dependencies() -> bool:
	var is_valid: bool = true

	if not explosion_effect_packed:
		push_error("Dependency missing: ‘explosion_effect_packed’ was not assigned.")
		is_valid = false

	if not pot_shattering_sound:
		push_error("Dependency missing: ‘pot_shattering_sound’ was not assigned.")
		is_valid = false

	return is_valid
