class_name PlayerHealthComponent extends Node2D

signal player_died
signal player_hit(damage: int)

@export var stats: PlayerStats

func _ready() -> void:
	await self.get_tree().process_frame
	if not stats:
		push_error("Dependency missing: ‘stats’ was not assigned.")

func take_damage(damage: int) -> void:
	stats.health -= damage
	player_hit.emit(stats.health)
	if stats.health <= 0:
		player_died.emit()
