extends Node2D

signal wants_to_throw_pot(pot_scene, start_position, target_position)
@onready var timer: Timer = %Timer
@export var wait_before_attack_max: float = 5.0
@export var wait_before_attack_min: float = 1.0
var basil_pot_packed: PackedScene = load('res://Objects/basil_pot.tscn')

func _ready() -> void:
	timer.start(_get_random_attack_time())

func _get_random_attack_time()->float:
	return randf_range(wait_before_attack_min,wait_before_attack_max)
func _on_timer_timeout() -> void:
	if GameManager.player_node and not GameManager.is_game_over:
		emit_signal(
			"wants_to_throw_pot",
			basil_pot_packed,
			%PotPos.global_position,
			GameManager.player_node.global_position # Wir fragen den GameManager nach dem Ziel
		)
		
		# Starte den Timer für den nächsten Wurf neu
		timer.start(_get_random_attack_time())
