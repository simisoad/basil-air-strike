extends Node2D

signal wants_to_throw_pot_signal(p_pot_scene, p_start_position, p_target_position)
@onready var pot_pos: Marker2D = %PotPos
@onready var throw_timer: Timer = %Timer

@export var wait_before_attack_max: float = 5.0
@export var wait_before_attack_min: float = 1.0


var basil_pot_packed: PackedScene = load('res://Objects/basil_pot.tscn')
var last_known_player_position: Vector2

func _ready() -> void:
	if Debug.enemys_active:
		self.throw_timer.start(_get_random_attack_time())
		GameManager.player_moved_signal.connect(_on_player_moved)

func _get_random_attack_time()->float:
	return randf_range(
			self.wait_before_attack_min,
			self.wait_before_attack_max
			)
	
func _on_player_moved(p_position: Vector2) -> void:
	self.last_known_player_position = p_position
	
func _on_timer_timeout() -> void:
	if not GameManager.is_game_over:
		self.wants_to_throw_pot_signal.emit(
			self.basil_pot_packed,
			self.pot_pos.global_position,
			self.last_known_player_position
		)
		self.throw_timer.start(_get_random_attack_time())
