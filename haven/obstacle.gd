extends StaticBody2D

@export var possible_sprites: Array[Texture2D] 

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	setup_random_obstacle()

func setup_random_obstacle() -> void:
	var chosen_texture: Texture2D
	

	if possible_sprites.is_empty():
		chosen_texture = preload("res://icon.svg")
	else:
		chosen_texture = possible_sprites[randi() % possible_sprites.size()]
	
	sprite_2d.texture = chosen_texture
	
	if collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		rect_shape.size = chosen_texture.get_size() * sprite_2d.scale
