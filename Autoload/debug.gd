extends Node

signal god_mode_signal(p_is_on: bool)

var debug_print_on: bool = true
var enemys_active: bool = true
var reset_per_input: bool = true
var god_mode: bool = false


func _ready() -> void:
	await self.get_tree().process_frame
	self.god_mode_signal.emit(self.god_mode)

func debug_print(message: String)-> void:
	if self.debug_print_on:
		print("Debug: ", message)
