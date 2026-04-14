extends Node

@warning_ignore("unused_signal")
signal sandbox_mode_set
signal money_changed(new_amount)
signal health_changed(new_amount)
signal wave_changed(new_amount)
signal game_over
signal damage_taken

var money: int = 650
var health: int = 150
var wave: int = 0
var is_fast := false
var _sandbox_mode := false
var show_congratulations_on_menu := false

var _saved_wave: int = 0
var _saved_wave_level: String = ""
var _on_reset_callback: Callable = Callable()
var level_node: Node2D
var layout_node: Node
var ui: Node
var cached_mouse_pos: Vector2 = Vector2.ZERO

func save_wave_for_level(level_path: String, wave_num: int) -> void:
	_saved_wave = wave_num
	_saved_wave_level = level_path

func get_saved_wave_for_level(level_path: String) -> int:
	if _saved_wave_level == level_path:
		return _saved_wave
	return 1

func _process(_delta: float) -> void:
	cached_mouse_pos = get_game_mouse_pos()

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
	if health < 0:
		health = 0
	health_changed.emit(health)
	damage_taken.emit()
	if health <= 0 and not _sandbox_mode:
		game_over.emit()

func change_wave(amount: int) -> void:
	if amount:
		wave = amount
	wave_changed.emit(wave)

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

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
	Engine.time_scale = 3.0 if is_fast else 1.0

func set_speed(fast: bool) -> void:
	is_fast = fast
	Engine.time_scale = 2.0 if fast else 1.0

func restart_game() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	reset()
	if _on_reset_callback.is_valid():
		_on_reset_callback.call()
	for tower in get_tree().get_nodes_in_group("towers"):
		tower.queue_free()
	if level_node and level_node.has_node("Path2D"):
		for child in level_node.get_node("Path2D").get_children():
			if child.name != "PathBlocker":
				child.queue_free()
	WaveManager.reset()
	if ui and ui.has_method("on_game_restarted"):
		ui.on_game_restarted()

func get_game_mouse_pos() -> Vector2:
	if not layout_node:
		return Vector2.ZERO
	var sub_vp = layout_node.get_node_or_null("GameViewport/SubViewport")
	if sub_vp:
		return sub_vp.get_mouse_position()
	if level_node:
		return level_node.get_local_mouse_position()
	return Vector2.ZERO
