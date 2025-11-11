class_name GameWorld extends Node2D
@export_category("Actors")
@export var player_packed: PackedScene
@export var player_stats_template: PlayerStats

@onready var player_spawner: WorldPlayerSpawnerComponent = %PlayerSpawnerComponent
@onready var level_loader: WorldLevelLoaderComponent = %LevelLoaderComponent

var current_level: BaseLevel
var player_instance: Player
var runtime_stats: PlayerStats
var level_database: LevelDatabase
func _ready() -> void:
	pass
func initialize(_level_database: LevelDatabase) -> void:
	if not _level_database:
		print("hö?")
	level_database = _level_database
	level_loader.level_database = level_database
	# TODO: Error-Handling
	runtime_stats = player_stats_template.duplicate()
	EventBus.level_retried.connect(_on_retry_level)
	await start_level(level_database.start_level_key)
	EventBus.next_level_reached.connect(_on_next_level)

func start_level(level_key: String) -> void:
	current_level = await level_loader.load_level(level_key)
	var player_start_transform: Transform2D = current_level.player_start.global_transform
	_spawn_player(player_start_transform)

func _spawn_player(at_transform: Transform2D) -> void:
	player_instance = player_spawner.spawn_player(player_packed, at_transform)
	add_child(player_instance)

	# Gib dem neuen Spieler die persistenten Stats und verbinde seine Signale
	player_instance.initialize(runtime_stats)
	player_instance.player_falled_signal.connect(_on_player_falled)
	player_instance.player_died_signal.connect(_on_player_died)

func _on_player_falled(fall_position: Vector2) -> void:
	_despawn_player()
	var reset_transform = Transform2D(0.0, fall_position + Vector2(0, -50))
	_spawn_player(reset_transform)

func _on_player_died() -> void:
	_despawn_player()
	runtime_stats.health = runtime_stats.initial_health
	runtime_stats.current_score = 0
	EventBus.player_died.emit()
	#GameStateManager.change_state(GameStateManager.State.GAME_OVER)

func _despawn_player() -> void:
	if is_instance_valid(player_instance):
		player_instance.queue_free()

func _on_retry_level() -> void:
	_spawn_player(current_level.player_start.global_transform)

func _on_next_level(next_level: String)-> void:
	_despawn_player()
	level_database.update_and_save_progress(next_level)
	start_level(next_level)
