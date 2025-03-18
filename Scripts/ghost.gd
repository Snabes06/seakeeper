extends Sprite2D

var timer = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a -= delta * 2
	timer -= delta
	if timer <= 0:
		queue_free()
