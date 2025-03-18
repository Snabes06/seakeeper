extends CanvasLayer

var timer = 0.5
var decay = 3
var damage_x = 1
signal upgrade(cost)
signal addstats(stat, percentage)

#Node access
@onready var amount = $Amount
@onready var health = $GameHealth
@onready var overlife = $Overlife
@onready var gameover = $GameOver
@onready var shop = $Shop

#HUD variables :: Stats
var speed = 100
var atr = 100
var hp = 100
var dashcc = 100
var frt = 100
@onready var spd_multi = $Multipliers/VBoxContainer/Speed
@onready var atr_multi = $Multipliers/VBoxContainer/Attraction
@onready var dashcc_multi = $Multipliers/VBoxContainer/Dashcc
@onready var frt_multi = $Multipliers/VBoxContainer/Bountiful
@onready var current_hp = $GameHealth/Hp

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

func _cost_multi() -> int:
	cost_multi += 0.05
	return cost_multi

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


func _update_multipliers(index: int) -> void:
	match(shop.upgrades.keys()[index]):
		"Zoomies":
			speed += shop.upgrade_stats.values()[index]*100
			spd_multi.text = "Spd: " + str(roundi(speed)) + "%"
			addstats.emit("Zoomies", shop.upgrade_stats.values()[index])
		"Rizz":
			atr += shop.upgrade_stats.values()[index]*100
			atr_multi.text = "Atr: " + str(roundi(atr)) + "%"
			addstats.emit("Rizz", shop.upgrade_stats.values()[index])
		"Lifeline": 
			overlife.max_value += shop.upgrade_stats.values()[index]
			overlife.value = overlife.max_value
			hp += shop.upgrade_stats.values()[index]
			overlife.size.x += shop.upgrade_stats.values()[index] * 6
			_update_current_hp()
		"Sigma":
			damage_x += 0.5
		"Leg Day":
			dashcc *= shop.upgrade_stats.values()[index]
			dashcc_multi.text = "cc: " + str(roundi(dashcc)) + "%"
			addstats.emit("Leg Day", shop.upgrade_stats.values()[index])
		"Bountiful":
			frt *= shop.upgrade_stats.values()[index]
			frt_multi.text = "Frt: " + str(roundi(frt)) + "%"
			addstats.emit("Bountiful", shop.upgrade_stats.values()[index])

func _on_upgrade_1_pressed() -> void:
	if amount.text.to_int() >= shop.upgrades.values()[shop.rand1] * cost_multi:
		_cost_multi()
		upgrade.emit(shop.upgrades.values()[shop.rand1] * cost_multi)
		_update_multipliers(shop.rand1)
		shop._randomize_shop(cost_multi)

func _on_upgrade_2_pressed() -> void:
	if amount.text.to_int() >= shop.upgrades.values()[shop.rand2] * cost_multi:
		_cost_multi()
		upgrade.emit(shop.upgrades.values()[shop.rand2] * cost_multi)
		_update_multipliers(shop.rand2)
		shop._randomize_shop(cost_multi)

func _on_upgrade_3_pressed() -> void:
	if amount.text.to_int() >= shop.upgrades.values()[shop.rand3] * cost_multi:
		_cost_multi()
		upgrade.emit(shop.upgrades.values()[shop.rand3] * cost_multi)
		_update_multipliers(shop.rand3)
		shop._randomize_shop(cost_multi)
