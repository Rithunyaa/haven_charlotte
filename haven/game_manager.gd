extends Node

@export var player_path: NodePath
@export var target_path: NodePath
@export var darkness_overlay_path: NodePath
@export var timer_label_path: NodePath
@export var level_label_path: NodePath
@export var game_over_screen_path: NodePath

@onready var player: CharacterBody2D = get_node(player_path)
@onready var target: Area2D = get_node(target_path)
@onready var darkness_overlay: CanvasModulate = get_node(darkness_overlay_path)
@onready var timer_label: RichTextLabel = get_node(timer_label_path)
@onready var level_label: RichTextLabel = get_node(level_label_path)
@onready var game_over_screen: Control = get_node(game_over_screen_path)
@onready var tent: StaticBody2D = $"../Obstacles/Tent"
@export var camera_path: NodePath
@onready var camera = get_node_or_null(camera_path)

var current_level: int = 1
var round_time: float = 10.0         
var round_time_left: float = 10.0

var max_level_darkness_time: float = 15.0 
var level_time_elapsed: float = 0.0       

var spawn_position: Vector2 = Vector2.ZERO
var is_game_over: bool = false

@export var obstacle_scenes: Array[PackedScene] 
var active_obstacles: Array = []

func _ready() -> void:
	if player:
		spawn_position = player.global_position
	
	if target and not target.body_entered.is_connected(_on_target_body_entered):
		target.body_entered.connect(_on_target_body_entered)
		
	if game_over_screen:
		game_over_screen.visible = false
		


	randomize_target_position()
	randomize_tent_position()
	
	reset_round()
	update_hud()

func _process(delta: float) -> void:
	if is_game_over:
		return
	
	round_time_left -= delta
	level_time_elapsed += delta
	
	update_cumulative_darkness()
	
	if round_time_left <= 3.0:
	
		var urgency = 3.0 - round_time_left 
		if camera:
			camera.shake_intensity = urgency * 2.5 
	else:
		if camera:
			camera.shake_intensity = 0.0
	
	
	if level_time_elapsed >= max_level_darkness_time:
		trigger_game_over()
		return
	
	if round_time_left <= 0.0:
		fail_round()
	
	update_hud()

func _input(event: InputEvent) -> void:
	if is_game_over and event is InputEventMouseButton and event.pressed:
		restart_game_from_beginning()

func update_hud() -> void:
	if timer_label:
		timer_label.text = "Time Left: " + str(snapped(round_time_left, 0.1)) + "s"
	if level_label:
		level_label.text = "Balloons Collected: " + str(current_level)

func update_cumulative_darkness() -> void:
	var darkness_progress = clamp(level_time_elapsed / max_level_darkness_time, 0.0, 1.0)
	var gray_value = clamp(1.0 - darkness_progress, 0.0, 1.0)
	darkness_overlay.color = Color(gray_value, gray_value, gray_value, 1.0)

func fail_round() -> void:
	if player:
		player.global_position = spawn_position
	round_time_left = round_time
	print("Time ran out! Pulled back to start.")

func reset_round() -> void:
	round_time_left = round_time

func _on_target_body_entered(body: Node2D) -> void:
	if body == player:
		advance_level()

func advance_level() -> void:
	current_level += 1
	level_time_elapsed = 0.0
	round_time_left = round_time
	
	var tween = create_tween()
	tween.tween_property(darkness_overlay, "color", Color(1, 1, 1, 1), 0.5)
	


	randomize_target_position()
	randomize_tent_position()
	
	if player:
		player.global_position = spawn_position
		
	print("Advanced to level: ", current_level)

func randomize_target_position() -> void:
	var min_distance: float = 360.0 
	var new_pos = Vector2.ZERO
	
	for i in range(10):
		var random_x = randf_range(-200, 200)
		var random_y = randf_range(-200, 200)
		new_pos = spawn_position + Vector2(random_x, random_y)
		
		if new_pos.distance_to(spawn_position) >= min_distance:
			break
			
	target.global_position = new_pos

func trigger_game_over() -> void:
	is_game_over = true
	
	if game_over_screen:
		game_over_screen.visible = true
		
	print("Game Over!")

func restart_game_from_beginning() -> void:
	is_game_over = false
	current_level = 1
	level_time_elapsed = 0.0
	round_time_left = round_time
	
	if game_over_screen:
		game_over_screen.visible = false
		
	darkness_overlay.color = Color(1, 1, 1, 1)
	
	if player:
		player.global_position = spawn_position

	randomize_target_position()
	reset_round()
	print("Restarted from Level 1")
	
func randomize_tent_position() -> void:
	var min_distance: float = 360.0 
	var new_pos = Vector2.ZERO
	
	for i in range(10):
		var random_x = randf_range(-200, 200)
		var random_y = randf_range(-200, 200)
		new_pos = spawn_position + Vector2(random_x, random_y)
		
		if new_pos.distance_to(spawn_position) >= min_distance:
			break
			
	tent.global_position = new_pos
