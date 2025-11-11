class_name GameStateMachineComponent extends Node

enum State { MAIN_MENU, PLAYING, PAUSED, GAME_OVER, LEVEL_SELECT }

signal state_changed(new_state)

var current_state: State = State.MAIN_MENU

func change_state(new_state: State):
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(new_state)
