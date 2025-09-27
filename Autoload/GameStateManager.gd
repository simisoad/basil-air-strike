extends Node

enum State { MAIN_MENU, PLAYING, PAUSED, GAME_OVER, LEVEL_SELECT }

signal state_changed_signal(new_state)
signal quit_game_signal()
signal start_game_signal()

var current_state: State = State.MAIN_MENU

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	await self.get_tree().process_frame
	self.state_changed_signal.emit(self.current_state)

func change_state(new_state: State) -> void:
	self.current_state = new_state
	self.state_changed_signal.emit(new_state)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ESC'):
		if current_state == State.MAIN_MENU:
			quit_game_signal.emit()
		elif current_state == State.PLAYING:
			change_state(State.PAUSED)
		elif current_state == State.PAUSED:
			change_state(State.PLAYING)
		elif current_state == State.GAME_OVER:
			change_state(State.MAIN_MENU)
		elif self.current_state == State.LEVEL_SELECT:
			change_state(State.MAIN_MENU)
			
