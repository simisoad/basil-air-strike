extends Node2D

@onready var player_start_transform: Transform2D
@onready var current_level_container: Node2D = %CurrentLevelContainer
@onready var level_manager: LevelManager = %LevelManager

var player_packed: PackedScene = load('res://Player/player.tscn')
var player: RigidBody2D

func _ready() -> void:
	await self.get_tree().process_frame
	await _load_level()
	_create_player(self.player_start_transform)
	GameManager.game_restarted_signal.connect(_on_game_restarted)
	GameManager.player_falled_signal.connect(_on_player_falled)
	GameManager.next_level_signal.connect(_on_next_level)

#hmm, ok, what if when the first level isn't called tutorial enymore?
func _load_level(p_next_level: String = "tutorial")-> void:
	_check_has_current_level()
	await self.get_tree().process_frame
	var load_path: String = level_manager.get_level(p_next_level)
	if not load_path:
		push_error("Level: %s was not found in LevelManager!" % p_next_level )
		return
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
	if is_instance_valid(self.player):
		self.player.queue_free()
	_create_player(self.player_start_transform)
	
func _on_player_falled(p_fall_position: Vector2) -> void:
	if is_instance_valid(self.player):
		self.player.queue_free()
	var reset_transform = Transform2D(0.0, p_fall_position + Vector2(0, -50)) # Etwas über dem Boden
	_create_player(reset_transform)

func _on_next_level(p_next_level: String)-> void:
	await _load_level(p_next_level)
	_on_game_restarted()
