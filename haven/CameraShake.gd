extends Camera2D

var shake_intensity: float = 0.0

func _process(delta: float) -> void:
	if shake_intensity > 0:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	else:
		offset = Vector2.ZERO 
