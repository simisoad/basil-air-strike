extends Control

@onready var player_health: Label = %PlayerHealth
@onready var score: Label = %Score

func _ready() -> void:
	GameManager.player_hit_signal.connect(_on_player_hit)
	#GameManager.game_restarted_signal.connect(_on_game_restarted)
	GameManager.score_updated_signal.connect(_on_score_update)
	
func _on_player_hit(p_player_health: int) -> void:
	self.player_health.text = str("Health: ", p_player_health)

#func _on_game_restarted(p_player_health: int, p_score: int) -> void:
	#self.player_health.text = str("Health: ", p_player_health)
	#self.score.text = str("Score: ", p_score)
	
func _on_score_update(_p_score: int) -> void:
	#nicht optimal mit dem score direkt aus dem GameManager
	#das signal liefert aber nur den zu neuen score-gewinn
	self.score.text = str("Score: ", GameManager.score)
