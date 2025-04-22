extends CanvasLayer

# 2 set timers and damage
var timer = 0.5
var decay = 3
var damage_x = 1

# hud-signals
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
@onready var dashcd_multi = $Multipliers/VBoxContainer/Dashcd
@onready var frt_multi = $Multipliers/VBoxContainer/Bountiful
@onready var current_hp = $GameHealth/Hp

# runs every frame,
# updates hp related functions therefore progressing the game
# also resulting in the end of the game.
func _process(delta: float) -> void:
	current_hp.text = str(roundi(health.value + overlife.value)) + "/" + str(roundi(health.max_value + overlife.max_value))
	_decay_overlife(delta)
	if overlife.value > 0:
		_remove_from_overlife(delta)
	else:
		_remove_from_health(delta)
	if health.value <= 0:
		_end_game()

# removes health from player
func _remove_from_health(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		health.value -= damage_x
		timer = 0.5

# removes overlife health from player *is prioritized so that it is removed first
func _remove_from_overlife(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		overlife.value -= damage_x
		timer = 0.5

# decays 1 hp max overlife every 3 seconds
func _decay_overlife(delta: float) -> void:
	decay -= delta
	if decay <= 0:
		if overlife.max_value > 0:
			overlife.max_value -= 1
			overlife.size.x -= 6
		decay = 3

# adds player health when picking up trash, will likely be replaced by different system in future updates.
func _add_to_health() -> void:
	if health.value == 100:
		overlife.value += 1
	else:
		health.value += 1

# ends game
func _end_game() -> void:
	gameover.show() # changes the visibilty of the gameover text to true.
	get_tree().paused = true # pauses the scenetree.

# connected to button 1 in shop.
func _on_upgrade_1_pressed() -> void:
	_collective_upgrade_function(shop.rand1)

# connected to button 2 in shop.
func _on_upgrade_2_pressed() -> void:
	_collective_upgrade_function(shop.rand2)

# connected to button 3 in shop.
func _on_upgrade_3_pressed() -> void:
	_collective_upgrade_function(shop.rand3)

# determines if the player has enough trash to purchase upgrade.
func _collective_upgrade_function(index: int) -> void:
	if amount.text.to_int() >= upgrade[index]["Cost"] * shop.upgrade_cost_multipliers[index]:
		remove.emit(upgrade[index]["Cost"] * shop.upgrade_cost_multipliers[index])
		_update_multipliers(index)

# matches button_pressed with upgrade to execute,
# upgrades are derived from .json file.
func _update_multipliers(index: int) -> void:
	match(upgrade[index]["Name"]):
		"Zoomies":
			# updates hud elements for speed.
			speed += upgrade[index]["Value"]*100 
			spd_multi.text = "Spd: " + str(roundi(speed)) + "%"
			
			addstats.emit("Zoomies", upgrade[index]["Value"]) # sends a signal increasing players speed.
		"Rizz":
			# updates hud elements for attraction.
			atr += upgrade[index]["Value"]*100
			atr_multi.text = "Atr: " + str(roundi(atr)) + "%"
			
			addstats.emit("Rizz", upgrade[index]["Value"]) # sends a signal increasing players attraction radius.
		"Lifeline": 
			# increases both total hp and overlife
			overlife.max_value += upgrade[index]["Value"]
			overlife.value = overlife.max_value
			hp += upgrade[index]["Value"]
			
			# increases size of overlife bar and total hp display over hp bar.
			overlife.size.x += upgrade[index]["Value"] * 6
			current_hp.text = str(roundi(health.value + overlife.value)) + "/" + str(roundi(health.max_value + overlife.max_value))
		"Sigma":
			print("not")
		"Leg Day":
			# updates hud elements for attraction.
			dashcd *= upgrade[index]["Value"]
			dashcd_multi.text = "Dash: " + str(roundi(dashcd)) + "%"
			
			addstats.emit("Leg Day", upgrade[index]["Value"]) # sends a signal reducing players dash cooldown.
		"Bountiful":
			# updates hud elements for trash gain.
			frt *= upgrade[index]["Value"]
			frt_multi.text = "Frt: " + str(roundi(frt)) + "%"
			
			addstats.emit("Bountiful", upgrade[index]["Value"]) # sends a signal increasing the multiplier when picking up trash.
			
	shop.upgrade_cost_multipliers[index] += pow(shop.upgrade_cost_multipliers[index], 2)
	shop._randomize_shop() # randomizes the shop items.
