extends Node2D

# node-access
@onready var spawn_timer: Timer = get_node("Timer")
@onready var trash_container: Node2D = get_node("TrashContainer")

# @export: allows tweaking properties in inspector window.
@export var trash_scene: PackedScene = preload("res://Scenes/trash.tscn")
@export var max_trash: int = 50

func _ready():
	randomize()

func spawnItem():
	if trash_container.get_child_count() >= max_trash:
		spawn_timer.stop()
		return
	var instance = trash_scene.instantiate()  # Instance a piece of trash.
	instance.global_position = getRandomScreenPosition()  # Position randomly on the screen.
	trash_container.add_child(instance) # Adds the node to the scene tree.

func getRandomScreenPosition() -> Vector2:
	var x = randf_range(-370, 370) # selects a random x cordinate on screen.
	var y = randf_range(-250, 250) # selects a random y cordinate on screen.
	return Vector2(x, y) # returns both x and y as a coordinate/vector.
