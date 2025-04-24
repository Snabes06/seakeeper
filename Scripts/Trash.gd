extends Node2D

var collected: bool = false

# Node-Access
@onready var sprite = $Sprite2D
@onready var collision_shape = $Area2D/CollisionShape2D

func _ready():
	# Enable collision detection for instanced items
	collision_shape.set_deferred("disabled", false)

# Reciver method for body nodes entering
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "PickupArea" and not collected:
		body.get_parent().on_trash_collected() # +1 trash
		_collect_trash(body)

# Counts the trash as collected, plays a pickup effect and removes the node from scene tree
func _collect_trash(body: Node2D):
	# Mark as collected to prevent multiple pickups
	collected = true
	collision_shape.set_deferred("disabled", true)  # Disable further collisions
	_add_effects(body)

func _add_effects(body: Node2D) -> void:
	var shrink = create_tween()
	shrink.tween_property(self, "scale", Vector2(0, 0), 0.2) # Shrink
	shrink.tween_callback(Callable(self, "queue_free")) # Remove node
