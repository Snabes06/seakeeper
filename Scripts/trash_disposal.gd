extends Sprite2D


var tossed = false



@onready var count = $Count


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not tossed:
		count.text = str(1)
