extends Panel

##Upgrade names and cost
var upgrades = {"Bountiful": 20, "Zoomies": 10,
"Rizz": 30, "Lifeline": 20, "Sigma": 50, "Leg Day": 20}

##Upgrade desc and stats
var upgrade_stats = {"Increases Trash Collected by 2x": 2, "Increases Movement Speed by 20%": 0.20,
"Increases Attraction by 500%": 5, "Grants 10 ''Overhealth''": 10,
"Stops the progress bar for 20 seconds": 20, "Decreases Dash Cooldown by 10%": 0.9}

var rand1
var rand2
var rand3

@onready var up1 = $HBoxContainer/Upgrade1
@onready var up2 = $HBoxContainer/Upgrade2
@onready var up3 = $HBoxContainer/Upgrade3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	_randomize_shop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_open_shop()

func _randomize_shop() -> void:
	rand1 = randi_range(0, upgrades.size() - 1)
	up1.text = str(upgrades.keys()[rand1]) + "\n" + "Price:" + str(upgrades.values()[rand1]) + " trash\n" + upgrade_stats.keys()[rand1]
	rand2 = randi_range(0, upgrades.size() - 1)
	up2.text = str(upgrades.keys()[rand2]) + "\n" + "Price:" + str(upgrades.values()[rand2]) + " trash\n" + upgrade_stats.keys()[rand2]
	rand3 = randi_range(0, upgrades.size() - 1)
	up3.text = str(upgrades.keys()[rand3]) + "\n" + "Price:" + str(upgrades.values()[rand3]) + " trash\n" + upgrade_stats.keys()[rand3]
	

func _open_shop() -> void:
	if Input.is_action_just_pressed("open_shop"):
		if visible == false:
			visible = true
			get_tree().paused = true
		else:
			visible = false
			get_tree().paused = false
