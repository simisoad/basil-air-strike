extends Node2D

@onready var player_start_transform: Transform2D
@onready var current_level_container: Node2D = %CurrentLevelContainer

var player_packed: PackedScene = load('res://Player/player.tscn')
var player: RigidBody2D

func _ready() -> void:
	await _load_level(GameManager.start_level_key)
	_create_player(self.player_start_transform)
	GameManager.game_restarted_signal.connect(_on_game_restarted)
	GameManager.player_falled_signal.connect(_on_player_falled)
	GameManager.next_level_signal.connect(_on_next_level)
	GameManager.player_died_signal.connect(_on_player_died)
#hmm, ok, what if when the first level isn't called tutorial enymore?
func _load_level(p_next_level: String )-> void:
	_check_has_current_level()
	await self.get_tree().process_frame
	var load_path: String = LevelsManager.get_level(p_next_level)
	if not load_path:
		push_error("Level: %s was not found in LevelManager!" % p_next_level)
		#Fallback:
		load_path = LevelsManager.get_level(LevelsManager.get_first_level())

	var level_packed: PackedScene = load(load_path)
	var current_level: BaseLevel = level_packed.instantiate() as BaseLevel
	self.current_level_container.add_child(current_level)
	await self.get_tree().process_frame
	self.player_start_transform = current_level.player_start.global_transform

func _check_has_current_level()->void:
	if self.current_level_container.get_child_count() > 0:
		var childs: Array = self.current_level_container.get_children()
		for child: Node in childs:
			child.queue_free()

func _create_player(p_transform: Transform2D) -> void:
	self.player = self.player_packed.instantiate()
	self.player.global_transform = p_transform
	self.call_deferred("add_child", self.player)

func _on_game_restarted()-> void:
	_remove_player()
	_create_player(self.player_start_transform)

func _on_player_died() -> void:
	call_deferred("_remove_player")

func _remove_player() -> void:
	if is_instance_valid(self.player):
		self.player.queue_free()


func _on_player_falled(p_fall_position: Vector2) -> void:
	if is_instance_valid(self.player):
		self.player.queue_free()
	var reset_transform = Transform2D(0.0, p_fall_position + Vector2(0, -50)) # Etwas über dem Boden
	_create_player(reset_transform)

func _on_next_level(p_next_level: String)-> void:
	LevelsManager.update_and_save_progress(p_next_level)
	await _load_level(p_next_level)
	_on_game_restarted()
