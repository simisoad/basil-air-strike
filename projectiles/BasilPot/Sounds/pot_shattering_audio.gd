class_name ShatterSound extends AudioStreamPlayer2D

func _init(pot_shattering_sound: AudioStreamRandomizer) -> void:
	self.stream = pot_shattering_sound
	self.finished.connect(_on_finished)

func _on_finished() -> void:
	self.queue_free()
