extends CanvasLayer

var timer = 0.5
var decay = 3
var damage_x = 1
signal remove(cost)
signal addstats(stat, percentage)

#Node access
@onready var amount = $Amount
@onready var health = $GameHealth
@onready var overlife = $Overlife
@onready var gameover = $GameOver
@onready var shop = $Shop

## Json objects
@onready var json = load("res://Classes/CreateUpgrade.tres").get_data()
@onready var upgrade = json["Upgrade"]

#HUD variables :: Stats
var speed = 100
var atr = 100
var hp = 100
var dashcd = 100
var frt = 100
@onready var spd_multi = $Multipliers/VBoxContainer/Speed
@onready var atr_multi = $Multipliers/VBoxContainer/Attraction
@onready var dashcd_multi = $Multipliers/VBoxContainer/Dashcc
@onready var frt_multi = $Multipliers/VBoxContainer/Bountiful
@onready var current_hp = $GameHealth/Hp

#Necessary variable for usage before updating
var cost_multi = 1

#Runs every frame.
#Updates everything HUD related and controlls the progress of the game.
#Also ends the game.
func _process(delta: float) -> void:
	_update_current_hp()
	_decay_overlife(delta)
	if overlife.value > 0:
		_remove_from_overlife(delta)
	else:
		_remove_from_health(delta)
	if health.value <= 0:
		_end_game()

#The damage curve is right now x^2
#Would possibly change to another formula in the future.
func _damage_curve() -> int:
	var damage = pow(damage_x, 2)
	return damage

func _cost_curve() -> void:
	cost_multi += 0.1

func _stat_cost_curve(stat: float) -> void:
	stat = pow(stat, 2)

#Updates the text on the hp label over the progressbar on the hud
func _update_current_hp() -> void:
	current_hp.text = str(roundi(health.value + overlife.value)) + "/" + str(roundi(health.max_value + overlife.max_value))

func _remove_from_health(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		health.value -= _damage_curve()
		timer = 0.5

func _remove_from_overlife(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		overlife.value -= _damage_curve()
		timer = 0.5

func _decay_overlife(delta: float) -> void:
	decay -= delta
	if decay <= 0:
		if overlife.max_value > 0:
			overlife.max_value -= 1
			overlife.size.x -= 6
		decay = 3

func _add_to_health() -> void:
	if health.value == 100:
		overlife.value += 1
	else:
		health.value += 1

func _end_game() -> void:
	gameover.show()

func _on_upgrade_1_pressed() -> void:
	_collective_upgrade_function(shop.rand1)

func _on_upgrade_2_pressed() -> void:
	_collective_upgrade_function(shop.rand2)

func _on_upgrade_3_pressed() -> void:
	_collective_upgrade_function(shop.rand3)

func _collective_upgrade_function(index: int) -> void:
	if amount.text.to_int() >= upgrade[index]["Cost"] * cost_multi * shop.upgrade_cost_multipliers[index]:
		remove.emit(upgrade[index]["Cost"] * cost_multi * shop.upgrade_cost_multipliers[index])
		_update_multipliers(index)

func _update_multipliers(index: int) -> void:
	match(upgrade[index]["Name"]):
		"Zoomies":
			speed += upgrade[index]["Value"]*100
			spd_multi.text = "Spd: " + str(roundi(speed)) + "%"
			addstats.emit("Zoomies", upgrade[index]["Value"])
		"Rizz":
			atr += upgrade[index]["Value"]*100
			atr_multi.text = "Atr: " + str(roundi(atr)) + "%"
			addstats.emit("Rizz", upgrade[index]["Value"])
		"Lifeline": 
			overlife.max_value += upgrade[index]["Value"]
			overlife.value = overlife.max_value
			hp += upgrade[index]["Value"]
			overlife.size.x += upgrade[index]["Value"] * 6
			_update_current_hp()
		"Sigma":
			print("not")
		"Leg Day":
			dashcd *= upgrade[index]["Value"]
			dashcd_multi.text = "cd: " + str(roundi(dashcd)) + "%"
			addstats.emit("Leg Day", upgrade[index]["Value"])
		"Bountiful":
			frt *= upgrade[index]["Value"]
			frt_multi.text = "Frt: " + str(roundi(frt)) + "%"
			addstats.emit("Bountiful", upgrade[index]["Value"])
			
	shop.upgrade_cost_multipliers[index] += pow(shop.upgrade_cost_multipliers[index], 2)
	_cost_curve()
	shop._randomize_shop(cost_multi)
