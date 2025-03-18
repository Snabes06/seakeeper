extends Node2D

var collected: bool = false

@onready var sprite = $Sprite2D
@onready var collision_shape = $Area2D/CollisionShape2D
signal count

func _ready():
	# Enable collision detection
	collision_shape.set_deferred("disabled", false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "PickupArea" and not collected:
		count.emit()
		collect_trash()

func collect_trash():
	# Mark as collected to prevent multiple pickups
	collected = true
	collision_shape.set_deferred("disabled", true)  # Disable further collisions
	# Optional: Play a pickup effect (like shrinking or fading out)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)  # Shrink
	tween.tween_callback(Callable(self, "queue_free"))  # Remove node
