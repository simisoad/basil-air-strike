class_name GameGUI extends CanvasLayer

@onready var main_menu: Control = %MainMenu
@onready var pause_menu: Control = %PauseMenu
@onready var game_over_screen: Control = %GameOverScreen
@onready var hud: Control = %HUD
@onready var level_select: Control = %LevelSelect

@onready var button_continue_game: Button = %ButtonContinueGame
@onready var select_menu_button: OptionButton = %SelectMenuButton

var state_machine: GameStateMachineComponent
var level_database: LevelDatabase

func initialize(_level_database: LevelDatabase) -> void:
	level_database = _level_database
	# TODO: Error-Handling
	state_machine.state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(state_machine.current_state)

func _set_level_to_select() -> void:
	# HACK: this may be a litte hacky?
	select_menu_button.clear()
	for level in level_database.get_all_levels():
		select_menu_button.add_item(level)
		if level == level_database.load_highest_level():
			return

func _check_is_continue_possible() -> void:
	if level_database.load_highest_level() == "tutorial":
		button_continue_game.disabled = true
	else:
		button_continue_game.disabled = false

func _on_game_state_changed(new_state: GameStateMachineComponent.State) -> void:
	# Zuerst alles ausblenden
	main_menu.hide()
	pause_menu.hide()
	game_over_screen.hide()
	hud.hide()
	level_select.hide()

	# Dann das richtige Menü einblenden
	match new_state:
		state_machine.State.MAIN_MENU:
			_check_is_continue_possible()
			main_menu.show()
		state_machine.State.PLAYING:
			hud.show()
		state_machine.State.PAUSED:
			pause_menu.show()
		state_machine.State.GAME_OVER:
			game_over_screen.show()
		state_machine.State.LEVEL_SELECT:
			_set_level_to_select()
			level_select.show()

func _on_button_continue_game_pressed() -> void:
	var highest_level = level_database.load_highest_level()
	level_database.start_level_key = highest_level
	EventBus.game_started.emit()
	state_machine.change_state(state_machine.State.PLAYING)

func _on_button_new_game_pressed() -> void:
	var first_level = level_database.get_first_level()
	level_database.start_level_key = first_level
	EventBus.game_started.emit()
	state_machine.change_state(state_machine.State.PLAYING)

func _on_button_quit_game_pressed() -> void:
	state_machine.quit_game_signal.emit()

func _on_resume_button_pressed() -> void:
	state_machine.change_state(state_machine.State.PLAYING)

func _on_main_menu_button_pressed() -> void:
	state_machine.change_state(state_machine.State.MAIN_MENU)

func _on_retry_level_pressed() -> void:
	EventBus.level_retried.emit()
	state_machine.change_state(state_machine.State.PLAYING)

func _on_play_selected_level_pressed() -> void:
	var highest_level = select_menu_button.get_item_text(select_menu_button.get_selected_id())
	level_database.start_level_key = highest_level
	EventBus.game_started.emit()
	state_machine.change_state(state_machine.State.PLAYING)

func _on_button_level_select_pressed() -> void:
	state_machine.change_state(state_machine.State.LEVEL_SELECT)
