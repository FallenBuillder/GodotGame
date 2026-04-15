extends Node2D

var game_over_scene = preload("res://Game/Scenes/UI/Game UI/Game Over/game_over.tscn")
var game_menu_scene = preload("res://Game/Scenes/UI/Game UI/Game Menu/game_menu.tscn")

const STARTING_MONEY = 9999999
const STARTING_HEALTH = 9999999

func _ready() -> void:
	var layout = GameManager.layout_node
	GameManager.ui = layout.get_node("Game UI")
	GameManager.level_node = self
	GameManager._sandbox_mode = true
	GameManager.sandbox_mode_set.emit()
	GameManager._on_reset_callback = func():
		GameManager.money = STARTING_MONEY
		GameManager.health = STARTING_HEALTH
		GameManager.money_changed.emit(GameManager.money)
		GameManager.health_changed.emit(GameManager.health)
		GameManager._sandbox_mode = true
		GameManager.sandbox_mode_set.emit()

	WaveManager.setup_path($Path2D)
	GameManager.game_over.connect(_on_game_over)

	if GameManager.ui:
		GameManager.ui.is_sandbox = true
		GameManager.ui.set_sandbox_mode()

	var ml = layout.get_node_or_null("ShopInfoPanel/VBoxContainer/MoneyContainer/ShopMoneyLabel")
	var hl = layout.get_node_or_null("ShopInfoPanel/VBoxContainer/HealthContainer/ShopHealthLabel")
	if ml:
		ml.mouse_filter = Control.MOUSE_FILTER_STOP
		ml.gui_input.connect(_on_money_label_input)
	if hl:
		hl.mouse_filter = Control.MOUSE_FILTER_STOP
		hl.gui_input.connect(_on_health_label_input)

	call_deferred("_apply_sandbox_values")

	if layout.has_method("show_sandbox_wave_select"):
		layout.show_sandbox_wave_select()

func _apply_sandbox_values() -> void:
	GameManager.money = STARTING_MONEY
	GameManager.health = STARTING_HEALTH
	GameManager.money_changed.emit(GameManager.money)
	GameManager.health_changed.emit(GameManager.health)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var canvas = CanvasLayer.new()
		canvas.layer = 20
		var parent = GameManager.layout_node if GameManager.layout_node else get_tree().root
		parent.add_child(canvas)
		canvas.add_child(game_menu_scene.instantiate())
		get_tree().paused = true

func deselect_all_towers() -> void:
	var tower_info = GameManager.layout_node.get_node_or_null("Tower Info") if GameManager.layout_node else null
	for tower in get_tree().get_nodes_in_group("towers"):
		tower.set_selected(false)
	if tower_info:
		tower_info.hide_info()

func spawn_specific_enemy(scene: PackedScene, is_camo: bool = false, is_regen: bool = false) -> void:
	var path_follow = PathFollow2D.new()
	var enemy = scene.instantiate()
	if is_camo:
		enemy.set_camo(true)
	if is_regen:
		enemy.set_regen(true)
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	$Path2D.add_child(path_follow)

func _on_game_over() -> void:
	var instance = game_over_scene.instantiate()
	var canvas = CanvasLayer.new()
	canvas.layer = 20
	get_tree().root.add_child(canvas)
	canvas.add_child(instance)
	if instance is Control:
		instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().paused = true

func _on_money_label_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_show_value_popup("Money", GameManager.money,
			func(v): GameManager.money = v; GameManager.money_changed.emit(v))

func _on_health_label_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_show_value_popup("Health", GameManager.health,
			func(v): GameManager.health = v; GameManager.health_changed.emit(v))

func _show_value_popup(label: String, current: int, on_confirm: Callable) -> void:
	var layout = GameManager.layout_node
	var dialog = AcceptDialog.new()
	dialog.title = "Set " + label
	var line = LineEdit.new()
	line.text = str(current)
	dialog.add_child(line)
	layout.add_child(dialog)
	dialog.popup_centered(Vector2(300, 100))
	line.call_deferred("select_all")
	line.call_deferred("grab_focus")
	var apply = func():
		if line.text.is_valid_int():
			on_confirm.call(int(line.text))
		dialog.queue_free()
	dialog.confirmed.connect(apply)
	line.text_submitted.connect(func(_t): apply.call())

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		PlacementManager.cancel()
