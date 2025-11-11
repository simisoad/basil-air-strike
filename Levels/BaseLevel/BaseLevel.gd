class_name BaseLevel extends Node2D

@export var grandmas: Node2D
@export var player_start: Marker2D

func _ready() -> void:
	_connect_grandma_signals()
	_connect_signals()


func _connect_signals()-> void:
	EventBus.object_shattered.connect(_on_object_shattered)

func _connect_grandma_signals() -> void:
	if not grandmas: return
	for grandma in grandmas.get_children():
		grandma.wants_to_throw_pot_signal.connect(_on_grandma_wants_to_throw)
#uhh, viele parameter...
func _on_grandma_wants_to_throw(
			pot_scene: PackedScene,
			start_pos: Vector2,
			target_pos: Vector2,
			throw_force: float,
			) -> void:
	_on_pot_thrown(pot_scene, start_pos, target_pos, throw_force)

func _on_pot_thrown(
		pot_scene: PackedScene,
		start_pos: Vector2,
		target_pos: Vector2,
		throw_force: float
		) -> void:

	var pot: BasilPot = pot_scene.instantiate() as BasilPot
	pot.global_position = start_pos
	add_child(pot)
	pot.launch(target_pos, throw_force)

#Auch für diese Sounds den SoundManager nutzen!
func _on_object_shattered(object_pos: Vector2, effect: PackedScene, shatter_sound: AudioStreamPlayer2D) -> void:
	_add_particle_effect(object_pos, effect)
	_add_sound_effect(object_pos, shatter_sound)
#	AudioStreamPlayer2D
func _add_sound_effect(sound_pos: Vector2, sound: AudioStreamPlayer2D):
	sound.global_position = sound_pos
	sound.name = str(randi(), "sound_effect")
	if sound.get_parent() == null:
		add_child(sound)
		sound.play(0.1)

func _add_particle_effect(effect_pos: Vector2, effect: PackedScene):
	var explosion: GPUParticles2D = effect.instantiate()
	explosion.global_position = effect_pos
	add_child(explosion)
