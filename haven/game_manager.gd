extends Node

@export var player_path: NodePath
@export var target_path: NodePath
@export var darkness_overlay_path: NodePath
@export var timer_label_path: NodePath
@export var level_label_path: NodePath

@onready var player: CharacterBody2D = get_node(player_path)
@onready var target: Area2D = get_node(target_path)
@onready var darkness_overlay: CanvasModulate = get_node(darkness_overlay_path)
@onready var timer_label: RichTextLabel = get_node(timer_label_path)
@onready var level_label: RichTextLabel = get_node(level_label_path)

var current_level: int = 1
var max_time: float = 10.0
var time_left: float = 10.0
var darkness_level: float = 0.0 
var spawn_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if player:
		spawn_position = player.global_position
	
	if target and not target.body_entered.is_connected(_on_target_body_entered):
		target.body_entered.connect(_on_target_body_entered)
		
	reset_round_timer()
	update_hud()

func _process(delta: float) -> void:
	time_left -= delta
	
	if time_left <= 0.0:
		fail_round()
	
	update_hud()

func update_hud() -> void:
	if timer_label:
		timer_label.text = str(snapped(time_left, 0.1)) + "s"
	if level_label:
		level_label.text = "Level " + str(current_level)

func fail_round() -> void:
	if player:
		player.global_position = spawn_position
	
	
	darkness_level += 0.25 
	max_time = max(2.0, max_time - 2.0)
	

	if darkness_level >= 1.0:
		trigger_game_over()
		return
		
	
	var gray_value = clamp(1.0 - darkness_level, 0.0, 1.0)
	darkness_overlay.color = Color(gray_value, gray_value, gray_value, 1.0)
	
	reset_round_timer()

func reset_round_timer() -> void:
	time_left = max_time

func _on_target_body_entered(body: Node2D) -> void:
	if body == player:
		advance_level()

func advance_level() -> void:
	current_level += 1
	
	
	darkness_level = 0.0
	darkness_overlay.color = Color(1, 1, 1, 1)
	max_time = 10.0 
	
	
	randomize_target_position()
	
	
	if player:
		player.global_position = spawn_position
		
	reset_round_timer()
	print("You survived...")

func randomize_target_position() -> void:
	var random_x = randf_range(-300, 300)
	var random_y = randf_range(-300, 300)
	target.global_position = spawn_position + Vector2(random_x, random_y)

func trigger_game_over() -> void:
	print("Restarting...")
	current_level = 1
	darkness_level = 0.0
	max_time = 10.0
	darkness_overlay.color = Color(1, 1, 1, 1)
	
	if player:
		player.global_position = spawn_position
		
	reset_round_timer()
