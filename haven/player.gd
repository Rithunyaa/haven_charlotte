extends CharacterBody2D

@export var speed: float = 500.0

func _physics_process(delta: float) -> void:
	# Get movement input from Arrow keys or WASD
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize direction so diagonal movement isn't faster
	direction = direction.normalized()
	
	# Apply velocity and move the character using Godot's built-in collision
	velocity = direction * speed
	move_and_slide()
