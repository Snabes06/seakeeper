extends Node2D


@onready var spawner = $ItemSpawner
@onready var trashamount = $Player/Camera2D/HUD/Amount
@onready var HUD = $Player/Camera2D/HUD

var TRASH_COUNT = 0
var COLLECTION_MULTI = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner.connect("count", _add_trash)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
	spawner.spawn_item()

func _add_trash() -> void:
	TRASH_COUNT += COLLECTION_MULTI
	trashamount.text = str(roundi(TRASH_COUNT))
	HUD._add_to_health()


func _on_hud_upgrade(cost: Variant) -> void:
	TRASH_COUNT -= cost
	trashamount.text = str(roundi(TRASH_COUNT))


func _on_player_trashmulti(multi: Variant) -> void:
	COLLECTION_MULTI = multi
