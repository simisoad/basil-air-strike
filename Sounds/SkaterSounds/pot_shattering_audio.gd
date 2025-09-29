class_name ShatterSound extends AudioStreamPlayer2D


func _init() -> void:
	self.stream = load('res://Sounds/SkaterSounds/pot_shattering_audio.tres')
	self.finished.connect(_on_finished)

func _on_finished() -> void:
	self.queue_free()
