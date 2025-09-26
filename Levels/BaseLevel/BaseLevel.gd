class_name BaseLevel extends Node2D

@export var grandmas: Node2D
@export var player_start: Marker2D

func _ready() -> void:
	_connect_grandma_signals()
	_connect_signals()

func _connect_signals()-> void:
	GameManager.object_shattered_signal.connect(_on_object_shattered)
	
func _connect_grandma_signals() -> void:
	if not self.grandmas: return
	for grandma in grandmas.get_children():
		grandma.wants_to_throw_pot_signal.connect(_on_grandma_wants_to_throw)

func _on_grandma_wants_to_throw(p_pot_scene: PackedScene, p_start_pos: Vector2, p_target_pos: Vector2) -> void:
	_on_pot_thrown(p_pot_scene, p_start_pos, p_target_pos)

func _on_pot_thrown(p_pot_scene: PackedScene, p_start_pos: Vector2, p_target_pos: Vector2) -> void:
	var pot: BasilPot = p_pot_scene.instantiate() as BasilPot
	pot.global_position = p_start_pos
	self.add_child(pot)
	pot.launch(p_target_pos, pot.throw_force)

func _on_object_shattered(p_position: Vector2, p_effect: PackedScene) -> void:
	var explosion: GPUParticles2D = p_effect.instantiate()
	explosion.global_position = p_position
	self.add_child(explosion)
