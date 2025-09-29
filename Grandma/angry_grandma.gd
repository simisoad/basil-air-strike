extends Node2D

signal wants_to_throw_pot_signal(p_pot_scene, p_start_position, p_target_position)
@onready var pot_pos: Marker2D = %PotPos
@onready var throw_timer: Timer = %ThrowTimer
@onready var warn_timer: Timer = %WarnTimer
@onready var warn_label: Label = %WarnLabel
@onready var fake_pot: Sprite2D = %FakePot


@export var wait_before_attack_max: float = 5.0
@export var wait_before_attack_min: float = 1.0
@export var warn_time: float = 0.5

var basil_pot_packed: PackedScene = load('res://Objects/BasilPot/basil_pot.tscn')
var last_known_player_position: Vector2


func _ready() -> void:
	self.fake_pot.visible = false
	if Debug.enemys_active:
		self.throw_timer.start(_get_random_attack_time())
		GameManager.player_moved_signal.connect(_on_player_moved)
		_warn_label_setup()

func _warn_label_setup() -> void:
	self.warn_label.visible = false
	self.warn_label.pivot_offset = self.warn_label.size/2
	
func  _process(_delta: float) -> void:
	if self.warn_label.visible == true:
		self.warn_label.scale = lerp(
				self.warn_label.scale,
				Vector2(2.0, 2.0),
				0.2)
func _get_random_attack_time()->float:
	return randf_range(
			self.wait_before_attack_min,
			self.wait_before_attack_max
			)
	
func _on_player_moved(p_position: Vector2) -> void:
	self.last_known_player_position = p_position




func _on_timer_timeout() -> void:
	self.warn_label.visible = true
	self.fake_pot.visible = true
	self.warn_label.scale = Vector2.ONE
	SoundManager.play_angry_grandma_no_sound()
	warn_timer.start(warn_time)


func _on_warn_timer_timeout() -> void:
	self.warn_label.visible = false
	warn_timer.stop()
	if GameStateManager.current_state == GameStateManager.State.PLAYING:
		self.wants_to_throw_pot_signal.emit(
			self.basil_pot_packed,
			self.pot_pos.global_position,
			self.last_known_player_position
		)
		self.throw_timer.start(_get_random_attack_time())
		self.fake_pot.visible = false
