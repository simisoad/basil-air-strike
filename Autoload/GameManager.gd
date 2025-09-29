# GameManager.gd
extends Node
#Signals
signal player_hit_signal(p_remaining_health: int)
signal player_died_signal
signal score_add_signal(p_add_score: int)
signal score_updated_signal(p_new_score: int)
signal game_restarted_signal #(p_health: int, p_score: int)
signal next_level_signal(p_level: String)
signal player_moved_signal(p_position: Vector2)
signal object_shattered_signal(p_position: Vector2, p_effect: PackedScene, shatter_sound: ShatterSound)
signal player_falled_signal(p_fall_position: Vector2)

#Const
const PLAYER_HEALTH_START: int = 300
#vars:
var player_health: int = PLAYER_HEALTH_START
var score: int = 0
var start_level_key: String = ""

func _ready() -> void:
	#signal for adding new score
	self.score_add_signal.connect(_on_score_update)
	GameStateManager.start_game_signal.connect(_restart_game)
	#for HUD:
	await self.get_tree().process_frame
	self.player_hit_signal.emit(self.player_health)
	self.score_updated_signal.emit(self.score)

func _input(p_event: InputEvent) -> void:
	if Debug.reset_per_input:
		if GameStateManager.current_state == GameStateManager.State.PLAYING:
			if p_event.is_action_pressed("Reset"):
				self._restart_game()

func on_player_hit(p_damage: int) -> void:
	if GameStateManager.current_state != GameStateManager.State.PLAYING:
		return
	self.player_health -= p_damage
	self.player_hit_signal.emit(self.player_health)

	if player_health <= 0:
		self.player_died_signal.emit()
		GameStateManager.change_state(GameStateManager.State.GAME_OVER)

func _restart_game() -> void:
	self.player_health = self.PLAYER_HEALTH_START
	self.score = 0
	self.game_restarted_signal.emit()
	self.score_updated_signal.emit(self.score)
	self.player_hit_signal.emit(self.player_health)

	
func _on_score_update(p_new_score: int) -> void:
	self.score += p_new_score
	self.score_updated_signal.emit(self.score)
