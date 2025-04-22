extends Node2D

@onready var spawner = $ItemSpawner

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"): 
		get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
	spawner.spawn_item()
