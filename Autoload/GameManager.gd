# GameManager.gd
extends Node

# Globale Zustandsvariablen
const PLAYER_HEALTH_START: int = 3
var player_health: int = 3
var score: int = 0
var is_game_over: bool = false

# Eine Referenz auf den Spieler, damit jeder, der sie braucht, hier nachfragen kann
# statt selbst die Szene zu durchsuchen.
var player_node: RigidBody2D = null

# Das ist unsere zentrale "Event-Schaltfläche". Andere Nodes können diese Signale
# senden, und wir (oder die UI) können darauf reagieren.
signal player_hit(remaining_health)
signal player_died
signal score_updated(new_score)
signal game_restarted

func _ready() -> void:
	# Hier könnte man das Laden/Anzeigen der UI anstoßen
	pass

# Funktion, damit der Spieler sich bei uns registrieren kann
func register_player(p_node: RigidBody2D) -> void:
	player_node = p_node

# Diese Funktion wird aufgerufen, wenn der Spieler getroffen wird
func on_player_hit(damage: int = 1) -> void:
	if is_game_over: return
	
	player_health -= damage
	emit_signal("player_hit", player_health)
	print("Player hit! Health remaining: ", player_health)
	
	if player_health <= 0:
		is_game_over = true
		emit_signal("player_died")
		print("Game Over!")
		
		# für den Anfagn einfach reset
		restart_game()

# Funktion, um das Spiel zurückzusetzen
func restart_game() -> void:
	player_health = PLAYER_HEALTH_START
	score = 0
	is_game_over = false
	emit_signal("game_restarted")
	print("Game Restarted!")
