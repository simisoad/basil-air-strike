# GameManager.gd
extends Node
#Signals
signal player_hit_signal(p_remaining_health: int)
signal player_died_signal
signal score_updated_signal(p_new_score: int)
signal game_restarted_signal
signal next_level_signal(p_level: String)
signal player_moved_signal(p_position: Vector2)
signal object_shattered_signal(p_position: Vector2, p_effect: PackedScene)
#Const
const PLAYER_HEALTH_START: int = 10

var player_health: int = PLAYER_HEALTH_START
var score: int = 0
var is_game_over: bool = false

func _ready() -> void:
	self.score_updated_signal.connect(_on_score_update)
	pass

func _input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed("Reset"):
		self._restart_game()

func on_player_hit(p_damage: int = 1) -> void:
	if self.is_game_over: return
	self.player_health -= p_damage
	self.player_hit_signal.emit(self.player_health)
	print("Player hit! Health remaining: ", self.player_health)
	
	if player_health <= 0:
		self.is_game_over = true
		self.player_died_signal.emit()
		print("Game Over!")
		# für den Anfagn einfach reset
		_restart_game()

func _restart_game() -> void:
	self.player_health = self.PLAYER_HEALTH_START
	self.score = 0
	self.is_game_over = false
	self.game_restarted_signal.emit()
	print("Game Restarted!")
	
func _on_score_update(p_new_score: int) -> void:
	self.score += p_new_score
