extends RigidBody2D

signal was_hit
# == Steuerungsvariablen (im Inspector anpassen) ==
@export_group("Bewegung am Boden")
@export var move_force: float = 800.0         # Kraft für die Beschleunigung
@export var max_speed: float = 800.0          # Maximale horizontale Geschwindigkeit

@export_group("Sprung")
@export var jump_force: float = 600.0         # Impulskraft für den Sprung
@export var jump_force_x: float = 50.0
@export_group("Physik & Stabilisierung")
# Wie stark der Skater in der Luft rotiert werden kann
@export var control_torque: float = 1000000.0


# == Node-Referenzen ==
@onready var skateboard_shape: CollisionShape2D = %CollisionShapeSkateboard 
@onready var can_jump_ray: RayCast2D = %CanJumpRay
@onready var on_ground_ray_front: RayCast2D = %OnGroundRayFront
@onready var on_ground_ray_rear: RayCast2D = %OnGroundRayRear

var player_fallen: bool = false



func _ready() -> void:
	GameManager.register_player(self)

func _physics_process(delta: float) -> void:
	#_on_skater_hit()
	# Hole die Eingabe des Spielers einmal pro Frame.
	var move_direction = Input.get_axis("Move_Left", "Move_Right")
	var torque_dir = Input.get_axis("Torque_Left", "Torque_Right")
	
	# Prüfe, ob der Skater am Boden ist.
	if _is_on_ground():
		# LOGIK AM BODEN
		_handle_ground_movement(move_direction)
		#_stabilize_rotation(delta)
		if Input.is_action_just_pressed("Break"):
			_break()

	_handle_torque_control(torque_dir, delta)

	# Die Sprung-Logik wird immer geprüft, funktioniert aber nur am Boden.
	if Input.is_action_just_pressed("Jump") and _can_jump():
		_perform_jump(torque_dir)


# Funktion für die Bewegung am Boden
func _handle_ground_movement(direction: float) -> void:
	# Nur beschleunigen, wenn die maximale Geschwindigkeit nicht überschritten ist.
	if abs(linear_velocity.x) < max_speed or (sign(linear_velocity.x) != direction and direction != 0):
		var force_position = skateboard_shape.position
		apply_force(Vector2(direction * move_force * self.mass, 0), force_position)

func _break() -> void:
	self.linear_velocity = Vector2.ZERO
# Funktion für die Rotations-Steuerung in der Luft
func _handle_torque_control(direction: float, delta: float) -> void:
	var torque = direction * control_torque * self.mass * delta
	apply_torque(torque)


# Funktion für den Sprung
func _perform_jump(direction: float) -> void:
	# Setze die vertikale Geschwindigkeit zurück für einen konstanten Sprung.
	linear_velocity.y = 0
	# Wende einen Impuls an für einen schnellen, kräftigen Sprung.
	apply_central_impulse(Vector2(
			direction * jump_force_x * self.mass, 
			-jump_force * self.mass
			))


# Hilfsfunktion, die prüft, ob der RayCast den Boden berührt.
func _is_on_ground() -> bool:
	if on_ground_ray_front.is_colliding() or on_ground_ray_rear.is_colliding():
		return true
	return false
	
func _can_jump() -> bool:
	return can_jump_ray.is_colliding()

func _on_skater_hit() -> bool:
	
	print(self.get_colliding_bodies())
	return false





func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Projectiles"):
		GameManager.on_player_hit()
		return
		

	
	var shape_owner: Node2D = shape_owner_get_owner(local_shape_index)
	#var hit_shape_name = shape_owner.name
	#print(hit_shape_name)
	if shape_owner.is_in_group("HurtPlayer") and !player_fallen:
		player_fallen = true
		#Transform2D(rotation: float, position: Vector2)
		
		print(shape_owner.get_groups())
		print("You fell!")
		call_deferred("_player_falled")
		# schlecht:
		GameManager.on_player_hit(1)
		
func _player_falled() -> void:
	await get_tree().process_frame
	self.global_transform = Transform2D(0.0, self.global_position + Vector2(0, 15))
	player_fallen = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("LevelSuccess"):
		print("sali")
