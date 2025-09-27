extends Control

@onready var player_health: Label = %PlayerHealth
@onready var score: Label = %Score

func _ready() -> void:
	GameManager.player_hit_signal.connect(_on_player_hit)
	GameManager.score_updated_signal.connect(_on_score_update)
	
func _on_player_hit(p_player_health: int) -> void:
	self.player_health.text = str("Health: ", p_player_health)

func _on_score_update(p_score: int) -> void:
	self.score.text = str("Score: ", p_score)
