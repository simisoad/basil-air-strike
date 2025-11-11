
class_name WorldPlayerSpawnerComponent extends Node2D

func spawn_player(p_player_packed: PackedScene, p_transform: Transform2D) -> Player:
	if not p_player_packed:
		push_error("Keine Player-Szene zum Spawnen übergeben!")
		return null

	var new_player: Player = p_player_packed.instantiate()
	new_player.global_transform = p_transform
	return new_player
