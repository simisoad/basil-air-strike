extends Node

@onready var state_machine: GameStateMachineComponent = %StateMachineComponent
@onready var gui: GameGUI = $GUI
@export var level_database: LevelDatabase

@export var world_scene: PackedScene
var current_world: GameWorld

func _ready() -> void:
	level_database._ready()
	# TODO: Error-Handling!!
	await self.get_tree().process_frame
	gui.state_machine = state_machine
	gui.initialize(level_database)
	EventBus.player_died.connect(_on_player_died)
	EventBus.game_started.connect(_on_start_game)
	state_machine.state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(state_machine.current_state)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ESC'):
		if state_machine.current_state == state_machine.State.MAIN_MENU:
			_on_game_quit()
		elif state_machine.current_state == state_machine.State.PLAYING:
			state_machine.change_state(state_machine.State.PAUSED)
		elif state_machine.current_state == state_machine.State.PAUSED:
			state_machine.change_state(state_machine.State.PLAYING)
		elif state_machine.current_state == state_machine.State.GAME_OVER:
			state_machine.change_state(state_machine.State.MAIN_MENU)
		elif state_machine.current_state == state_machine.State.LEVEL_SELECT:
			state_machine.change_state(state_machine.State.MAIN_MENU)
	elif event.is_action_pressed('Jump'):
		if state_machine.current_state == state_machine.State.GAME_OVER:
			EventBus.level_retried.emit()
			state_machine.change_state(state_machine.State.PLAYING)

func _on_start_game():
	if current_world == null:
		current_world = world_scene.instantiate()
		add_child(current_world)
		current_world.initialize(level_database)

func _on_game_state_changed(new_state: GameStateMachineComponent.State):
	match new_state:
		state_machine.State.MAIN_MENU:
			get_tree().paused = false
			if current_world != null:
				current_world.queue_free()
				current_world = null
		state_machine.State.PLAYING:
			self.get_tree().paused = false
		state_machine.State.PAUSED:
			self.get_tree().paused = true
		state_machine.State.GAME_OVER:
			self.get_tree().paused = true

func _on_game_quit() -> void:
	self.get_tree().quit()

func _on_player_died():
	state_machine.change_state(state_machine.State.GAME_OVER)
