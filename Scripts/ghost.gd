extends Sprite2D

var timer = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 1 # modulate.a represents the opacity for the color applied to the node, turning it to one basically means 100% opacity.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a -= delta * 2 # Reduces opacity every frame.
	timer -= delta # Makes the timer tick every frame.
	if timer <= 0: # Detects when the timer reaches 0 or below.
		queue_free() # freeing the node from the scenetree, removing it in the process.
