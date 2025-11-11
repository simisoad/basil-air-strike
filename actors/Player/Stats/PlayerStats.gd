class_name PlayerStats extends Resource

@export_category("Health and Damage")
@export_group("Health")
@export var health: int = 15
## Should be the same as health.
@export var initial_health: int = 15

@export_group("Player Damage")
## How much damage the player takes when fall
@export var fall_damage: int = 1
## How much damgage the player takes when hit by a pot
@export var pot_damage: int = 5
## How long it takes the player to standup
@export var standup_time: float = 0.25
## How long the player will be invincible after a hit
@export var invincible_time: float = 0.5

@export_category("Movement")
@export_group("Movement on Floor")
@export var move_force: float = 800.0
@export var max_speed: float = 800.0

@export_group("Jump Settings")
@export var jump_force: float = 600.0
@export var jump_force_x: float = 50.0

@export_group("Torque Control")
@export var control_torque: float = 1000000.0 #hmm, ja so gehts
@export_category("Scoring")
## How much tolerance in degree.
@export_group("Score Settings")
@export var score_tolerance: int = 20
## How much sore for reached rotation (without score_tolerance).
@export var scores: Dictionary = {
		"180": 250,
		"270": 500,
		"360": 1000,
		"450": 1500,
		"720": 3000,
}
## If this score is reached the amount of lifes from lifes_for_score will be added.
@export var add_life_for_score: int = 3000
## The amount of lifes that will be added when reached the value of add_life_for_score.
@export var lifes_for_score: int = 10

# REVIEW: Is this the right place for this:
var current_score: int = 0
