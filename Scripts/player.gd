extends CharacterBody2D

signal trashmulti(multi)


# Constants
# @export: Allows tweaking properties in inspector window
@export var MOVEMENT_SPEED = 100
@export var DASH_SPEED = 250
@export var DASH_DURATION = 0.25
@export var DASH_COOLDOWN = 0.5
@export var GHOST_SPACING = 1

# Multipliers
var SPEED_MULTI = 1
var RANGE_MULTI = 1
var DASH_COOLDOWN_REDUCTION_MULTI = 1
var TRASH_MULTI = 1

# Variables
var IS_DASHING = false
var COOLDOWN_TIMER: float = 0.0
var DASH_TIMER: float = 0.0
var VELOCITY = Vector2.ZERO
var GHOST = preload("res://Scenes/Ghost.tscn")

# Node-access
@onready var animation = $Sprite2D

# 
func _physics_process(delta: float) -> void:
	_inputs()
	_dash(delta)
	_animation_handler()
	move_and_slide()


func _update_multipliers(stat: String, percentage: float) -> void:
	match(stat):
		"Zoomies":
			SPEED_MULTI += percentage
		"Rizz":
			$PickupArea/PickupRadius.scale += Vector2(percentage, percentage)
		"Leg Day":
			DASH_COOLDOWN_REDUCTION_MULTI *= percentage
		"Bountiful":
			TRASH_MULTI *= percentage
			trashmulti.emit(TRASH_MULTI)
		

# Checks player input, inputs while dashing are ignored
func _inputs() -> void:
	if IS_DASHING:
		return
	else:
		VELOCITY = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = VELOCITY.normalized() * MOVEMENT_SPEED * SPEED_MULTI
		if Input.is_action_just_pressed("dash") and COOLDOWN_TIMER <= 0:
			_start_dash()

# Enables the dash
# Applies constants, velocity & ghosts to dash
func _start_dash() -> void:
	IS_DASHING = true
	DASH_TIMER = DASH_DURATION
	COOLDOWN_TIMER = DASH_COOLDOWN * DASH_COOLDOWN_REDUCTION_MULTI
	velocity = VELOCITY.normalized() * DASH_SPEED * SPEED_MULTI
	_create_ghosts()

# Disables the dash using a timer
func _dash(delta: float) -> void:
	if IS_DASHING:
		DASH_TIMER -= delta
		if DASH_TIMER <= 0:
			IS_DASHING = false
			velocity = Vector2.ZERO
	if COOLDOWN_TIMER > 0:
		COOLDOWN_TIMER -= delta

# Instantiates the dash-ghosts that fade out
func _create_ghosts() -> void:
	for i in range(4):
		await get_tree().create_timer(0.04).timeout
		var instance = GHOST.instantiate()
		if VELOCITY.x > 0:
			instance.global_position = Vector2(global_position.x + i, global_position.y)
			get_parent().add_child(instance)
		elif VELOCITY.x < 0:
			instance.global_position = Vector2(global_position.x - i, global_position.y + i)
			get_parent().add_child(instance)
		elif VELOCITY.y > 0:
			instance.global_position = Vector2(global_position.x, global_position.y + i)
			get_parent().add_child(instance)
		elif VELOCITY.y < 0:
			instance.global_position = Vector2(global_position.x, global_position.y - 1)
			get_parent().add_child(instance)

# Handles animations for movement/dashing
func _animation_handler() -> void:
	if IS_DASHING:
		animation.speed_scale = 0.5
		animation.play("dash_jump")
	else:
		animation.speed_scale = 1
		if(VELOCITY == Vector2.ZERO):
			animation.play("idle")
		else:
			animation.play("walk")
