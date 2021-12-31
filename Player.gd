extends CharacterBody3D

signal damage_taken
signal health_updated

@onready var Head = $Head
@onready var PlayerHUD = $PlayerHUD
@onready var PlayerMenu = $PlayerMenu

@export var gravity = 0.98
@export var acceleration = 5
@export var deceleration = 10
@export var movement_speed = 10
@export var jump_power = 30
@export var sprint_multiplier : float = 2.0

var min_look_angle : float = -89.9
var max_look_angle : float = 89.9
@export var mouse_sensitivity : float = 0.3

@export var health : int = 50
@export var max_health : int = 100


func _ready():
	motion_velocity = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	_handle_key_input(delta)


func _unhandled_input(event):
	_handle_look_input_event(event)


func _physics_process(delta):
	_apply_gravity(delta)
	move_and_slide()


func _apply_gravity(delta):
	if is_on_floor() == false:
		motion_velocity.y -= gravity
	

func game_paused() -> bool:
	return Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED


func _handle_key_input(delta):
	if game_paused() == false:
		var movement_direction = Vector3()
		var head_direction = Head.global_transform.basis
		if Input.is_action_pressed('move_left'):
			movement_direction -= head_direction.x
		if Input.is_action_pressed('move_right'):
			movement_direction += head_direction.x
		if Input.is_action_pressed('move_forward'):
			movement_direction -= head_direction.z
		if Input.is_action_pressed('move_back'):
			movement_direction += head_direction.z
		movement_direction = movement_direction.normalized()
		
		# calculate movement this frame
		var move_speed_this_frame = movement_speed
		if Input.is_action_pressed('sprint'):
			move_speed_this_frame *= sprint_multiplier
			
		if movement_direction.length() > 0:
			# do acceleration
			motion_velocity = motion_velocity.lerp(move_speed_this_frame * movement_direction, acceleration * delta)
		else:
			# do deceleration
			motion_velocity = motion_velocity.lerp(movement_speed * movement_direction, deceleration * delta)
			
		if Input.is_action_just_pressed('jump') and is_on_floor():
			motion_velocity.y += jump_power
			
		
			

	# This can be moved out to a game state handler, but is implemented to help close the window
	if Input.is_action_just_pressed('open_menu'):
		toggle_pause()


func _handle_look_input_event(event):
	if event is InputEventMouseMotion and game_paused() == false:
		var look_movement = event.relative
		
		# left/right look
		rotate_y(deg2rad(-look_movement.x * mouse_sensitivity))
		
		# up/down look, clamp it so the camera doesn't "flip over"
		Head.rotate_x(deg2rad(-look_movement.y * mouse_sensitivity))
		Head.rotation.x = clamp(Head.rotation.x, deg2rad(min_look_angle), deg2rad(max_look_angle))

		# locks Z axis, because linear combinations of X and Y can change Z rotation over time
		Head.rotation.z = 0


func toggle_pause():
	set_physics_process(!is_physics_processing())
	if game_paused() == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	PlayerMenu.toggle_menu()


func die():
	get_tree().quit(0)


func take_damage(amount : int = 0):
	health -= amount
	
	if health <= 0:
		die()
	
	emit_signal('damage_taken')
	emit_signal('health_updated')


func heal_damage(amount : int = 0):
	health = min(max_health, health + amount)
	emit_signal('health_updated')
