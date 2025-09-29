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
	
	
#Auch für diese Sounds den SoundManager nutzen!
func _on_object_shattered(p_position: Vector2, p_effect: PackedScene, p_shatter_sound: AudioStreamPlayer2D) -> void:
	_add_particle_effect(p_position, p_effect)
	_add_sound_effect(p_position, p_shatter_sound)
#	AudioStreamPlayer2D
func _add_sound_effect(p_position: Vector2, p_sound: AudioStreamPlayer2D):
	p_sound.global_position = p_position
	p_sound.name = str(randi(), "sound_effect")
	if p_sound.get_parent() == null:
		self.add_child(p_sound)
		p_sound.play(0.1)
	

	
func _add_particle_effect(p_position: Vector2, p_effect: PackedScene):
	var explosion: GPUParticles2D = p_effect.instantiate()
	explosion.global_position = p_position
	self.add_child(explosion)
