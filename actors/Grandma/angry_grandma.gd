extends Node2D

signal wants_to_throw_pot_signal(pot_scene, start_position, target_position, thorw_force)
@onready var pot_pos: Marker2D = %PotPos
@onready var throw_timer: Timer = %ThrowTimer
@onready var warn_timer: Timer = %WarnTimer
@onready var warn_label: Label = %WarnLabel
@onready var fake_pot: Sprite2D = %FakePot

@onready var sound_component: AngryGrandmaSoundComponent = $Components/SoundComponent

@export_group("Pot throw Options")
@export var basil_pot_packed: PackedScene
@export var wait_before_attack_max: float = 5.0
@export var wait_before_attack_min: float = 1.0
@export var warn_time: float = 0.5 ## Time before actually throwing the pot
@export var throw_force: float = 1000.0
## Possiblity to add an Area2D so the grandma only throws a pot when player is in this Area.
@export var throw_activate_aera: Area2D


var last_known_player_position: Vector2
var is_grandma_active: bool = false

func _ready() -> void:
	if not basil_pot_packed:
		push_error("Dependency missing: ‘basil_pot_packed’ was not assigned.")
		return
	EventBus.player_moved.connect(_on_player_moved)
	fake_pot.visible = false
	_warn_label_setup()

	if throw_activate_aera == null:
		_activate_grandma()
	else:
		throw_activate_aera.monitoring = true
		throw_activate_aera.area_entered.connect(_on_activate_area_entered)
		throw_activate_aera.area_exited.connect(_on_activate_area_exited)

func _activate_grandma() -> void:
	is_grandma_active = true
	throw_timer.start(_get_random_attack_time())


func _warn_label_setup() -> void:
	warn_label.visible = false
	warn_label.pivot_offset = warn_label.size/2

func  _process(_delta: float) -> void:
	if warn_label.visible == true:
		warn_label.scale = lerp(
				warn_label.scale,
				Vector2(2.0, 2.0),
				0.2)
func _get_random_attack_time()->float:
	return randf_range(
			wait_before_attack_min,
			wait_before_attack_max
			)

func _on_player_moved(player_pos: Vector2) -> void:
	last_known_player_position = player_pos

func _on_timer_timeout() -> void:
	warn_label.visible = true
	fake_pot.visible = true
	warn_label.scale = Vector2.ONE
	sound_component.play_angry_grandma_no_sound()
	warn_timer.start(warn_time)


func _on_warn_timer_timeout() -> void:
	warn_label.visible = false
	warn_timer.stop()
	#if GameStateManager.current_state == GameStateManager.State.PLAYING:
	wants_to_throw_pot_signal.emit(
		basil_pot_packed,
		pot_pos.global_position,
		last_known_player_position,
		throw_force
	)
	if is_grandma_active:
		throw_timer.start(_get_random_attack_time())
	else:
		throw_timer.stop()
	fake_pot.visible = false

func _on_activate_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		_activate_grandma()

func _on_activate_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		is_grandma_active = false
