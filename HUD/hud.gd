extends CanvasLayer

@onready var player_health: Label = %PlayerHealth
@onready var score: Label = %Score

func _ready() -> void:
	_on_player_hit(GameManager.player_health)
	GameManager.player_hit_signal.connect(_on_player_hit)
	GameManager.game_restarted_signal.connect(_on_game_restarted)
	GameManager.score_updated_signal.connect(_on_score_update)
	
func _on_player_hit(p_player_health: int) -> void:
	self.player_health.text = str("Health: ", p_player_health)

func _on_game_restarted() -> void:
	self.player_health.text = str("Health: ", GameManager.PLAYER_HEALTH_START)
	
func _on_score_update(_score: int) -> void:
	self.score.text = str("Score: ", GameManager.score)
