extends Node

var money: int = 650
var health: int = 150
var wave: int = 0
var is_fast := false
var auto_start := false

var level_node: Node2D
var ui: Node

signal money_changed(new_amount)
signal health_changed(new_amount)
signal wave_changed(new_amount)
signal game_over

func reset() -> void:
	money = 650
	health = 150
	wave = 0
	is_fast = false
	money_changed.emit(money)
	health_changed.emit(health)
	wave_changed.emit(wave)

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		health = 0
		game_over.emit()

func change_wave(amount: int) -> void:
	if amount:
		wave = amount
	wave_changed.emit(wave)

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func add_health(amount: int) -> void:
	health += amount
	health_changed.emit(health)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func lose_game() -> void:
	game_over.emit()

func speed_up() -> void:
	is_fast = !is_fast
	if is_fast:
		Engine.time_scale = 2.0
	else:
		Engine.time_scale = 1.0

func set_speed(fast: bool) -> void:
	is_fast = fast
	Engine.time_scale = 2.0 if fast else 1.0

func restart_game() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	reset()
	for tower in get_tree().get_nodes_in_group("towers"):
		tower.queue_free()
	if level_node and level_node.has_node("Path2D"):
		var path = level_node.get_node("Path2D")
		for child in path.get_children():
			if child.name != "PathBlocker":
				child.queue_free()
	WaveManager.reset()
