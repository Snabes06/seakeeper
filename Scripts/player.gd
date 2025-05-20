extends CharacterBody2D

# @export: Allows tweaking properties in inspector window
@export var HP = 100 ## Player max health
@export var TRASH = 0 ## Trash in player inventory
@export var MOVEMENT_SPEED = 100 ## Player movement speed
@export var DASH_SPEED = 250 ## Player dash speed
@export var DASH_DURATION = 0.25 ## Player dash duration
@export var DASH_COOLDOWN = 0.5 ## Player dash cooldown

# Multipliers
var speed_multi = 1
var range_multi = 1
var dash_cooldown_reduction_multi = 1
var trash_multi = 1

# Variables
var IS_DASHING = false
var COOLDOWN_TIMER: float = 0.0
var DASH_TIMER: float = 0.0
var VELOCITY = Vector2.ZERO
var GHOST = preload("res://Scenes/Ghost.tscn")

# Trash Counting
@onready var trash_display = $Camera2D/HUD/Amount
@onready var HUD = $Camera2D/HUD
var COLLECTED = 0

# Animations
@onready var animation = $Sprite2D

# Runs every frame
func _physics_process(delta: float) -> void:
	inputs()
	dash(delta)
	animationHandler()
	move_and_slide()

# Checks player input, inputs while dashing are ignored
func inputs() -> void:
	if IS_DASHING:
		return
	else:
		VELOCITY = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = VELOCITY.normalized() * MOVEMENT_SPEED * speed_multi
		if Input.is_action_just_pressed("dash") and COOLDOWN_TIMER <= 0:
			startDash()

# Enables the dash
# Applies constants, velocity & ghosts to dash
func startDash() -> void:
	IS_DASHING = true
	DASH_TIMER = DASH_DURATION
	COOLDOWN_TIMER = DASH_COOLDOWN * dash_cooldown_reduction_multi
	velocity = VELOCITY.normalized() * DASH_SPEED * speed_multi
	createGhosts()

# Disables the dash using a timer
func dash(delta: float) -> void:
	if IS_DASHING:
		DASH_TIMER -= delta
		if DASH_TIMER <= 0:
			IS_DASHING = false
			velocity = Vector2.ZERO
	if COOLDOWN_TIMER > 0:
		COOLDOWN_TIMER -= delta

# Instantiates the dash-ghosts that fade out
func createGhosts() -> void:
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
func animationHandler() -> void:
	if IS_DASHING:
		animation.speed_scale = 0.5
		animation.play("dash_jump")
	else:
		animation.speed_scale = 1
		if(VELOCITY == Vector2.ZERO):
			animation.play("idle")
		else:
			animation.play("walk")

# Increments
func on_trash_collected() -> void:
	HP += 1
	TRASH += 1 * trash_multi
	trash_display.text = str(roundi(TRASH))
	HUD.updateHealth()

# Removes trash points based on what was purchased from the shop 
func _remove(cost: Variant) -> void:
	TRASH -= cost
	trash_display.text = str(roundi(TRASH))

# Returned signal with the chosen stat increase for the player
func _update_multipliers(stat: String, percentage: float) -> void:
	match(stat):
		"Zoomies":
			speed_multi += percentage
		"Rizz":
			get_child(2).scale += Vector2(percentage, percentage)
		"Leg Day":
			dash_cooldown_reduction_multi *= percentage
		"Bountiful":
			trash_multi *= percentage
