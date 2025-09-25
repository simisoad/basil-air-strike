extends Node2D
@onready var player_start: Marker2D = %PlayerStart
@onready var skater_start_transform: Transform2D
@onready var grandmas: Node2D = %AngryGrandmas

var skater_packed: PackedScene = load('res://Player/Skater.tscn')
var player: RigidBody2D
var explosion_packed: PackedScene = load('res://Objects/pot_explode.tscn')

func _ready() -> void:
	self.skater_start_transform = player_start.global_transform
	_create_player()
	_connect_grandma_signals()
	GameManager.game_restarted.connect(_on_reset_skater)
	
func _create_player() -> void:
	player = skater_packed.instantiate()
	player.global_transform = self.skater_start_transform
	#await get_tree().process_frame
	#self.add_child(player)
	self.call_deferred("add_child", player)
	
func _connect_grandma_signals()-> void:
	var all_childs: Array = self.grandmas.get_children()
	for grandma in all_childs:
		grandma.wants_to_throw_pot.connect(_on_grandma_wants_to_throw_pot)
		
func _on_grandma_wants_to_throw_pot(pot_scene: PackedScene, start_pos: Vector2, target_pos: Vector2) -> void:
	var pot: RigidBody2D = pot_scene.instantiate()
	pot.global_position = start_pos
	self.add_child(pot)
	pot.launch(target_pos, 1000)
	pot.pot_shattered.connect(_on_pot_shattered)
	
func _on_pot_shattered(position: Vector2) -> void:
	var explosion: GPUParticles2D = explosion_packed.instantiate()
	explosion.global_position = position
	self.add_child(explosion)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset"):
		GameManager.restart_game()
		
func _on_reset_skater()-> void:
	print("Resetting skater")
	player.queue_free()
	_create_player()
	
