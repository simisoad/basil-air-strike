class_name BasilPot extends RigidBody2D

var explosion_effect_packed: PackedScene = load('res://Objects/BasilPot/Effects/pot_explode.tscn')
@onready var shatter_sound: ShatterSound = ShatterSound.new()


func launch(p_target_position: Vector2, p_impulse_strength: float) -> void:
	var direction: Vector2 = self.global_position.direction_to(p_target_position)
	var dir_normal: Vector2 = Vector2(-direction.y, direction.x)
	var target_vector: Vector2 = direction * p_impulse_strength
	var normal_vector: Vector2 = dir_normal * 200
	self.apply_impulse(target_vector+normal_vector)


func _on_body_entered(_p_body: Node) -> void:
	GameManager.object_shattered_signal.emit(
			self.global_position,
			self.explosion_effect_packed,
			self.shatter_sound,
			)
	self.queue_free()


func _on_selfdestruct_timer_timeout() -> void:
	self.queue_free()
