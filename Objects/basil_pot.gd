extends RigidBody2D
signal pot_shattered(position)

var explosion_packed: PackedScene = load('res://Objects/pot_explode.tscn')
var explosion: GPUParticles2D = explosion_packed.instantiate()

var force: float = 1000

func launch(target_position: Vector2, impulse_strength: float) -> void:
	var direction = self.global_position.direction_to(target_position)
	self.apply_impulse(direction * impulse_strength)
	
func _on_body_entered(body: Node) -> void:
	# Wir sagen der Welt, wo wir zerbrochen sind, damit sie eine Explosion erzeugen kann.
	emit_signal("pot_shattered", self.global_position)
	# Wir entfernen uns selbst aus der Szene.
	self.queue_free()
