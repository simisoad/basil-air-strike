class_name AngryGrandmaSoundComponent extends Node2D

@onready var angry_no_sound: AudioStreamPlayer2D = %NoSound

func play_angry_grandma_no_sound()-> void:
	angry_no_sound.play()
