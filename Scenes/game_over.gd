extends Label

var lost = false

func _process(delta: float) -> void:
	if visible and Input.is_action_just_pressed("escape"): # Requires esc to be pressed while the text is visible.
		get_tree().paused = false # Unpauses scenetree.
		get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn") # Changes current scene to the start menu.
