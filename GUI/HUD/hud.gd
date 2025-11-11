extends Control

@onready var player_health_label: Label = %PlayerHealthLabel
@onready var score_label: Label = %ScoreLabel

func _ready() -> void:
	EventBus.player_hit.connect(_on_player_hit)
	EventBus.player_score_updated.connect(_on_score_update)

func _on_player_hit(player_health: int) -> void:
	player_health_label.text = str("Health: ", player_health)

func _on_score_update(score: int) -> void:
	score_label.text = str("Score: ", score)
