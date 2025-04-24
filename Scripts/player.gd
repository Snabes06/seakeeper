extends CharacterBody2D

# @export: Allows tweaking properties in inspector window
@export var HP_MAX = 100 ## Player max health
@export var HP = 100 ## Player current health
@export var HP_OL_MAX = 0 ## Player max overlife
@export var HP_OL = 0 ## Player current overlife

@export var DAMAGE_INTERVAL = 0.5 ## Time between damage taken

@export var TRASH = 0 ## Player current trash

@export var MOVEMENT_SPEED = 100 ## Player movement speed
@export var DASH_SPEED = 250 ## Player dash speed
@export var DASH_DURATION = 0.25 ## Player dash duration
@export var DASH_COOLDOWN = 0.5 ## Player dash cooldown

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

# Trash Counting
@onready var HUD = $Camera2D/HUD

# Animations
@onready var animation = $Sprite2D

# Runs every frame
func _physics_process(delta: float) -> void:
	if HP_OL == 0:
		_take_damage(delta, 1) # Damage hp
	else:
		_take_ol_damage(delta, 1) # Damage overlife
	_inputs()
	_dash(delta)
	_animation_handler()
	move_and_slide()

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

func on_trash_collected() -> void:
	TRASH += 1 * TRASH_MULTI
	HUD.update_element("TRASH", TRASH)
	_heal_hp()

func _heal_hp() -> void:
	if HP < 100:
		HP += 1
	if HP == 100 and HP_OL < HP_OL_MAX:
		HP_OL += 1
	HUD.update_element("HP", HP)
	HUD.update_element("HP_OVERLIFE", HP_OL)

func _take_damage(delta: float, damage: int) -> void:
	DAMAGE_INTERVAL -= delta
	if DAMAGE_INTERVAL <= 0:
		HP -= damage
		HUD.update_element("HP", HP)
		HUD.update_element("HP_OVERLIFE", HP_OL)
		DAMAGE_INTERVAL = 0.5

func _take_ol_damage(delta: float, damage: int) -> void:
	DAMAGE_INTERVAL -= delta
	if DAMAGE_INTERVAL <= 0:
		HP_OL -= damage
		HUD.update_element("HP", HP)
		HUD.update_element("HP_OVERLIFE", HP_OL)
		DAMAGE_INTERVAL = 0.5

func _remove(cost: Variant) -> void:
	TRASH -= cost
	HUD.update_element("TRASH", TRASH)

func _update_multipliers(stat: String, value: float) -> void:
	match(stat):
		"Zoomies":
			SPEED_MULTI += value
		"Rizz":
			get_child(2).scale += Vector2(value, value)
		"Leg Day":
			DASH_COOLDOWN_REDUCTION_MULTI *= value
		"Bountiful":
			TRASH_MULTI *= value
		"Lifeline":
			HP_OL_MAX = value
			HP_OL = value
