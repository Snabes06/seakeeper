extends Label

const time = 10.0
const round_count = 10
const endless_time = 20.0

var timer = time
var round_number = 1

func _ready() -> void:
	self_modulate.a = 1

func _process(delta: float) -> void:
	if round_number >= round_count:
		endlessMode(delta)
	else:
		normalRounds(delta)

func normalRounds(delta: float) -> void:
	if self_modulate.a > 0.0:
		removeRoundChange(delta)
	timer -= delta
	$RoundTimer.text = str(snappedf(timer, 0.01))
	if timer <= 0.0:
		self_modulate.a = 1
		round_number += 1
		get_parent().damage_x += 0
		text = "Round " + str(round_number)
		timer = time

func endlessMode(delta: float) -> void:
	if self_modulate.a > 0.0:
		removeRoundChange(delta)
	timer -= delta
	$RoundTimer.text = str(snappedf(timer, 0.01))
	if timer <= 0.0:
		self_modulate.a = 1
		round_number += 1
		get_parent().damage_x += 5
		text = "Endless Round " + str(round_number - round_count)
		timer = endless_time

func removeRoundChange(delta: float) -> void:
	self_modulate.a -= delta/2
