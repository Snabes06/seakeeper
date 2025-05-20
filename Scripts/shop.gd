extends Panel

##Upgrade costmultipliers
var upgrade_cost_multipliers = [1, 1, 1, 1, 1, 1]

var rand1
var rand2
var rand3

@onready var up1 = $VBoxContainer/HBoxContainer/Upgrade1
@onready var up2 = $VBoxContainer/HBoxContainer/Upgrade2
@onready var up3 = $VBoxContainer/HBoxContainer/Upgrade3

## Json objects
@onready var json = load("res://Classes/CreateUpgrade.tres").get_data()
@onready var upgrade = json["Upgrade"] # list of upgrades


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	randomizeShop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	openShop()

func randomizeShop() -> void:
	rand1 = randi_range(0, upgrade.size() - 1)
	var upgrade1 = upgrade[rand1]
	up1.text = str(upgrade1["Name"]) + "\n" + "Price: " + str(roundi(upgrade1["Cost"] * upgrade_cost_multipliers[rand1])) + " trash\n" + upgrade1["Description"]
	rand2 = randi_range(0, upgrade.size() - 1)
	var upgrade2 = upgrade[rand2]
	up2.text = str(upgrade2["Name"]) + "\n" + "Price: " + str(roundi(upgrade2["Cost"] * upgrade_cost_multipliers[rand2])) + " trash\n" + upgrade2["Description"]
	rand3 = randi_range(0, upgrade.size() - 1)
	var upgrade3 = upgrade[rand3]
	up3.text = str(upgrade3["Name"]) + "\n" + "Price: " + str(roundi(upgrade3["Cost"] * upgrade_cost_multipliers[rand3])) + " trash\n" + upgrade3["Description"]

## Opens the shop when pressing the keybind
func openShop() -> void:
	if Input.is_action_just_pressed("open_shop"):
		if visible == false:
			visible = true
			get_tree().paused = true
		else:
			visible = false
			get_tree().paused = false


func _on_skip_pressed() -> void:
	randomizeShop()
