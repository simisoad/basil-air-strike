extends Node

@export var world_scene: PackedScene
var current_world: Node2D

func _ready() -> void:
	await self.get_tree().process_frame
	GameStateManager.start_game_signal.connect(_on_start_game)
	GameStateManager.state_changed_signal.connect(_on_game_state_changed)
	GameStateManager.quit_game_signal.connect(_on_game_quit)
	
func _on_start_game():
	if self.current_world == null:
		self.current_world = self.world_scene.instantiate()
		self.add_child(self.current_world)

func _on_game_state_changed(new_state: GameStateManager.State):
	match new_state:
		GameStateManager.State.MAIN_MENU:
			self.get_tree().paused = false
			if self.current_world != null:
				self.current_world.queue_free()
				self.current_world = null
		GameStateManager.State.PLAYING:
			self.get_tree().paused = false
		GameStateManager.State.PAUSED:
			self.get_tree().paused = true
		GameStateManager.State.GAME_OVER:
			self.get_tree().paused = false

func _on_game_quit() -> void:
	self.get_tree().quit()
