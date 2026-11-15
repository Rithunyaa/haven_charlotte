extends Node

@export var balloon_textures: Array[Texture2D]
@onready var target_sprite: Sprite2D = $Sprite2D 

@export var player_path: NodePath
@export var target_path: NodePath
@export var darkness_overlay_path: NodePath
@export var timer_label_path: NodePath
@export var level_label_path: NodePath
@export var game_over_screen_path: NodePath
@export var final_score_label_path: NodePath # <-- NEW: Path for your game over score text
@export var camera_path: NodePath

@onready var player: CharacterBody2D = get_node(player_path)
@onready var target: Area2D = get_node(target_path)
@onready var darkness_overlay: CanvasModulate = get_node(darkness_overlay_path)
@onready var timer_label: RichTextLabel = get_node(timer_label_path)
@onready var level_label: RichTextLabel = get_node(level_label_path)
@onready var game_over_screen: Control = get_node(game_over_screen_path)
@onready var final_score_label: RichTextLabel = get_node(final_score_label_path) # <-- NEW
@onready var camera = get_node_or_null(camera_path)
@onready var tent: StaticBody2D = $"../Obstacles/Tent"
@onready var get_balloon: AudioStreamPlayer = $"../get_balloon"

var total_survival_time: float = 15.0         
var round_time_left: float = 15.0

var current_score: int = 0 
var spawn_position: Vector2 = Vector2.ZERO
var is_game_over: bool = false

func _ready() -> void:
	if player:
		spawn_position = player.global_position
	
	if target and not target.body_entered.is_connected(_on_target_body_entered):
		target.body_entered.connect(_on_target_body_entered)
		
	if game_over_screen:
		game_over_screen.visible = false
		
	restart_game_from_beginning()

func _process(delta: float) -> void:
	if is_game_over:
		return
	
	round_time_left -= delta
	update_cumulative_darkness()
	
	if round_time_left <= 3.0:
		var urgency = 3.0 - round_time_left 
		if camera:
			camera.shake_intensity = urgency * 3.5
	else:
		if camera:
			camera.shake_intensity = 0.0
	
	if round_time_left <= 0.0:
		trigger_game_over()
		return
	
	update_hud()

func _input(event: InputEvent) -> void:
	if is_game_over and event is InputEventMouseButton and event.pressed:
		restart_game_from_beginning()

func update_hud() -> void:
	if timer_label:
		timer_label.text = "Time Left: " + str(snapped(round_time_left, 0.1)) + "s"
	if level_label:
		level_label.text = "Balloons Collected: " + str(current_score)

func update_cumulative_darkness() -> void:
	var progress = clamp(1.0 - (round_time_left / total_survival_time), 0.0, 1.0)
	var shade = clamp(1.0 - progress, 0.0, 1.0)
	darkness_overlay.color = Color(shade, shade, shade, 1.0)

func _on_target_body_entered(body: Node2D) -> void:
	$get_balloon.play()
	if body == player:
		collect_balloon()

func collect_balloon() -> void:
	current_score += 1
	randomize_target_position()
	randomize_tent_position()

func randomize_tent_position() -> void:
	var new_pos = Vector2.ZERO
	# Give it a wider search radius so it always finds a spot easily
	for i in range(30):
		var random_x = randf_range(-300, 300)
		var random_y = randf_range(-300, 300)
		new_pos = spawn_position + Vector2(random_x, random_y)
		
		if new_pos.distance_to(spawn_position) >= 120.0:
			break
			
	tent.global_position = new_pos

func randomize_target_position() -> void:
	var new_pos = Vector2.ZERO
	
	for i in range(30):
		var random_x = randf_range(-300, 300)
		var random_y = randf_range(-300, 300)
		new_pos = spawn_position + Vector2(random_x, random_y)
		
		# Ensure it's not on top of the player spawn AND not overlapping the tent
		var away_from_spawn = new_pos.distance_to(spawn_position) >= 100.0
		var away_from_tent = true
		
		if tent:
			away_from_tent = new_pos.distance_to(tent.global_position) >= 90.0
			
		if away_from_spawn and away_from_tent:
			break
			
	target.global_position = new_pos
	
	# --- FIXED: Randomly pick and assign a color texture from your array ---
	if not balloon_textures.is_empty() and target:
		var sprite = target.get_node_or_null("Sprite2D") # Looks for the Sprite2D child inside your target node
		if sprite:
			var random_texture = balloon_textures[randi() % balloon_textures.size()]
			sprite.texture = random_texture

func trigger_game_over() -> void:
	$AudioStreamPlayer2D.play()
	is_game_over = true
	round_time_left = 0.0
	
	if camera:
		camera.shake_intensity = 0.0
		
	if darkness_overlay:
		darkness_overlay.color = Color(0, 0, 0, 1) 
	
	# --- NEW: Update and show the final score label on the Game Over screen ---
	if final_score_label:
		final_score_label.text = "You collected " + str(current_score) + " balloons!"
		
	if game_over_screen:
		game_over_screen.visible = true 

func restart_game_from_beginning() -> void:
	is_game_over = false
	current_score = 0
	round_time_left = total_survival_time
	
	if game_over_screen:
		game_over_screen.visible = false
		
	if darkness_overlay:
		darkness_overlay.color = Color(1, 1, 1, 1) 
	
	if player:
		player.global_position = spawn_position

	randomize_target_position()
	randomize_tent_position()
	update_hud()
