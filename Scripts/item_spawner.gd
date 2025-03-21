extends Node2D

@onready var spawn_timer: Timer = get_node("Timer")
@onready var trash_container: Node2D = get_node("TrashContainer")

# Constants
# @export: Allows tweaking properties in inspector window
@export var trash_scene: PackedScene = preload("res://Scenes/trash.tscn")
@export var max_trash: int = 50

func _ready():
	randomize()

func _process(delta: float) -> void:
	pass

func spawn_item():
	if trash_container.get_child_count() >= max_trash:
		spawn_timer.stop()
		return
	var instance = trash_scene.instantiate()  # Instance a piece of trash
	instance.global_position = get_random_screen_position()  # Position randomly on the screen
	trash_container.add_child(instance)

func get_random_screen_position() -> Vector2:
	var x = randf_range(-370, 370)
	var y = randf_range(-250, 250)
	return Vector2(x, y)
