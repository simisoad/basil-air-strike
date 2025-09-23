extends Node2D
@onready var skater: RigidBody2D = %Skater
var skater_start_transfrom: Transform2D

func _ready() -> void:
	self.skater_start_transfrom = skater.global_transform

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset"):
		self.skater.linear_velocity = Vector2.ZERO
		self.skater.angular_velocity = 0.0
		self.skater.global_transform = self.skater_start_transfrom
