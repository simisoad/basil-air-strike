extends Node

@onready var world: Node2D = %World

func _ready() -> void:
	GameStateManager.state_changed_signal.connect(_on_game_state_changed)
	GameStateManager.quit_game_signal.connect(_on_game_quit)
	self.get_tree().paused = true
	
func _on_game_state_changed(new_state: GameStateManager.State):
	match new_state:
		GameStateManager.State.MAIN_MENU:
			self.get_tree().paused = true
		GameStateManager.State.PLAYING:
			self.get_tree().paused = false
		GameStateManager.State.PAUSED:
			self.get_tree().paused = true
		GameStateManager.State.GAME_OVER:
			self.get_tree().paused = true

func _on_game_quit() -> void:
	self.get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	await self.get_tree().process_frame
	self.get_tree().quit()
