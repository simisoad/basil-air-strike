extends CanvasLayer


@onready var player_health: Label = %PlayerHealth

func _ready() -> void:
	_on_player_hit(GameManager.player_health)
	GameManager.player_hit.connect(_on_player_hit)
	GameManager.game_restarted.connect(_on_game_restarted)
	
func _on_player_hit(p_player_health: int) -> void:
	player_health.text = str("Player Health: ", p_player_health)

func _on_game_restarted() -> void:
	player_health.text = str("Player Health: ", GameManager.PLAYER_HEALTH_START)
