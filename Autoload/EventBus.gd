extends Node

# --- PLAYER-EVENTS ---
signal player_hit(damage_amount: int)
signal player_died
signal player_health_updated(current_health: int)
signal player_score_updated(new_score: int)
signal player_moved(player_pos: Vector2)

# --- GAME-EVENTS ---
signal game_started
signal game_paused
signal game_resumed
signal object_shattered(object_pos: Vector2, effect: PackedScene, shatter_sound: AudioStreamPlayer2D)

# --- LEVEL-EVENTS ---
# REVIEW: signal names?
signal next_level_reached
signal level_retried
