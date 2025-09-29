extends CanvasLayer

@onready var main_menu: Control = %MainMenu
@onready var pause_menu: Control = %PauseMenu
@onready var game_over_screen: Control = %GameOverScreen
@onready var hud: Control = %HUD
@onready var level_select: Control = %LevelSelect

@onready var button_continue_game: Button = %ButtonContinueGame
@onready var select_menu_button: OptionButton = %SelectMenuButton


func _ready() -> void:
	GameStateManager.state_changed_signal.connect(_on_game_state_changed)
	_on_game_state_changed(GameStateManager.current_state)

func _set_level_to_select() -> void:
	for level in LevelsManager.get_all_levels():
		select_menu_button.add_item(level)
		if level == LevelsManager.load_highest_level():
			return

func _check_is_continue_possible() -> void:
	if LevelsManager.load_highest_level() == "tutorial":
		button_continue_game.disabled = true
	else:
		button_continue_game.disabled = false
	
func _on_game_state_changed(new_state: GameStateManager.State) -> void:
	# Zuerst alles ausblenden
	self.main_menu.hide()
	self.pause_menu.hide()
	self.game_over_screen.hide()
	self.hud.hide()
	self.level_select.hide()

	# Dann das richtige Menü einblenden
	match new_state:
		GameStateManager.State.MAIN_MENU:
			_check_is_continue_possible()
			self.main_menu.show()
		GameStateManager.State.PLAYING:
			self.hud.show()
		GameStateManager.State.PAUSED:
			self.pause_menu.show()
		GameStateManager.State.GAME_OVER:
			self.game_over_screen.show()
		GameStateManager.State.LEVEL_SELECT:
			_set_level_to_select()
			self.level_select.show()
			
func _on_button_continue_game_pressed() -> void:
	var highest_level = LevelsManager.load_highest_level()
	GameManager.start_level_key = highest_level
	GameStateManager.start_game_signal.emit()
	GameStateManager.change_state(GameStateManager.State.PLAYING)

func _on_button_new_game_pressed() -> void:
	var first_level = LevelsManager.get_first_level()
	GameManager.start_level_key = first_level
	GameStateManager.start_game_signal.emit()
	GameStateManager.change_state(GameStateManager.State.PLAYING)

func _on_button_quit_game_pressed() -> void:
	GameStateManager.quit_game_signal.emit()

func _on_resume_button_pressed() -> void:
	GameStateManager.change_state(GameStateManager.State.PLAYING)

func _on_main_menu_button_pressed() -> void:
	GameStateManager.change_state(GameStateManager.State.MAIN_MENU)

func _on_retry_level_pressed() -> void:
	GameStateManager.start_game_signal.emit()
	GameStateManager.change_state(GameStateManager.State.PLAYING)

func _on_play_selected_level_pressed() -> void:
	var highest_level = self.select_menu_button.get_item_text(self.select_menu_button.get_selected_id())
	GameManager.start_level_key = highest_level
	GameStateManager.start_game_signal.emit()
	GameStateManager.change_state(GameStateManager.State.PLAYING)

func _on_button_level_select_pressed() -> void:
	GameStateManager.change_state(GameStateManager.State.LEVEL_SELECT)
