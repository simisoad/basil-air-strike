class_name BasilPot extends RigidBody2D

var explosion_effect_packed: PackedScene = load('res://Objects/pot_explode.tscn')
var throw_force: float = 1000

func launch(p_target_position: Vector2, p_impulse_strength: float) -> void:
	var direction: Vector2 = self.global_position.direction_to(p_target_position)
	self.apply_impulse(direction * p_impulse_strength)
	
func _on_body_entered(_p_body: Node) -> void:
	GameManager.object_shattered_signal.emit(self.global_position, self.explosion_effect_packed)
	self.queue_free()
