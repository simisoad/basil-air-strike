class_name SoundComponent extends Node2D
@export_category("Rolling Sound Settings:")
@export var max_linear_volume: float = 400

@onready var skater_rolling_sound: AudioStreamPlayer2D = %RollingSound
@onready var skater_jump_sound: AudioStreamPlayer2D = %JumpSound
@onready var skater_landing_sound: AudioStreamPlayer2D = %LandingSound
@onready var skater_hurt_sound: AudioStreamPlayer2D = %HurtSound
@onready var health_added: AudioStreamPlayer = %HealthAdded

var physics_body: RigidBody2D

func _ready() -> void:
	await self.get_tree().process_frame
	if not physics_body:
		push_error("Dependency missing: ‘physics_body’ was not assigned.")

func play_skater_rolling_sound(p_is_in_air: bool)-> void:
	if not p_is_in_air:
		skater_rolling_sound.volume_linear = max(0.0, abs(physics_body.linear_velocity.x)/(max_linear_volume))
	else:
		skater_rolling_sound.volume_linear = lerpf(skater_rolling_sound.volume_linear, 0.0, 0.2)

func play_skater_jump_sound() -> void:
	if skater_jump_sound.is_playing():
		skater_landing_sound.stop()
	skater_jump_sound.play()

func play_skater_landing_sound() -> void:
	if skater_landing_sound.is_playing():
		skater_jump_sound.stop()
	skater_landing_sound.play()

func play_skater_hurt_sound(_damage: float) -> void:
	skater_hurt_sound.play()

func play_health_added_sound() -> void:
	health_added.play()
