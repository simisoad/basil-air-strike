extends Node
var debug_print_on: bool = true
var enemys_active: bool = true

func debug_print(message: String)-> void:
	if self.debug_print_on:
		print("Debug: ", message)
