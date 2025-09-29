extends Node2D
@onready var skater_rolling_sound: AudioStreamPlayer2D = %RollingSound
@onready var skater_jump_sound: AudioStreamPlayer2D = %JumpSound
@onready var skater_landing_sound: AudioStreamPlayer2D = %LandingSound
@onready var skater_hurt_sound: AudioStreamPlayer2D = %HurtSound
@onready var angry_no_sound: AudioStreamPlayer2D = %NoSound

func _ready() -> void:
	self.skater_rolling_sound.volume_linear = 0.0
	self.skater_hurt_sound.volume_linear = 10.0

func play_skater_rolling_sound(skater: Skater)-> void:
	#Hmm, eine private Methode aufrufen...
	if GameStateManager.current_state != GameStateManager.State.PLAYING:
		self.skater_rolling_sound.volume_linear = 0.0
		return
	if skater._is_on_ground():
		self.skater_rolling_sound.volume_linear = max(0.0, abs(skater.linear_velocity.x)/(skater.max_speed*0.5))
	else:
		self.skater_rolling_sound.volume_linear = lerpf(skater_rolling_sound.volume_linear, 0.0, 0.2)

func play_skater_jump_sound() -> void:
	if self.skater_jump_sound.is_playing():
		self.skater_landing_sound.stop()
	self.skater_jump_sound.play()

func play_skater_landing_sound() -> void:
	if self.skater_landing_sound.is_playing():
		self.skater_jump_sound.stop()
	self.skater_landing_sound.play()
	
func play_skater_hurt_sound() -> void:
	self.skater_hurt_sound.play()

func play_angry_grandma_no_sound()-> void:
	self.angry_no_sound.play()
