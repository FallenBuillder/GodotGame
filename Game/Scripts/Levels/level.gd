extends Node2D

var game_over_scene = preload("res://Game/Scenes/UI/Game UI/Game Over/game_over.tscn")
var settings_scene = preload("res://Game/Scenes/UI/Game UI/Game Menu/game_menu.tscn")

var _level_path: String = ""

@onready var path_arrow = $PathArrow

func _ready() -> void:
	_level_path = get_scene_file_path()
	var level_key = _level_path.get_file().get_basename()

	var layout = get_parent().get_parent().get_parent()
	GameManager.ui = layout.get_node("Game UI")
	GameManager.level_node = self
	GameManager.game_over.connect(_on_game_over)
	GameManager._sandbox_mode = false
	GameManager._on_reset_callback = Callable()
	GameManager.reset()

	WaveManager.setup_path($Path2D)
	WaveManager.set_level_max_wave(level_key)
	WaveManager.is_auto_start = SettingsManager.get_auto_start()

	if GameManager.ui and "current_level_key" in GameManager.ui:
		GameManager.ui.current_level_key = level_key

	var saved = GameManager.get_saved_wave_for_level(_level_path)
	if saved > 1 and GameManager.ui and GameManager.ui.has_method("set_start_wave"):
		GameManager.ui.set_start_wave(saved)
	
	if path_arrow:
		path_arrow.visible = true
		WaveManager.wave_started.connect(_hide_arrow)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var canvas = CanvasLayer.new()
		canvas.layer = 20
		var parent = GameManager.layout_node if GameManager.layout_node else get_tree().root
		parent.add_child(canvas)
		var settings = settings_scene.instantiate()
		canvas.add_child(settings)
		get_tree().paused = true

func _hide_arrow(_wave_num: int) -> void:
	if path_arrow:
		path_arrow.visible = false
	WaveManager.wave_started.disconnect(_hide_arrow)

func deselect_all_towers() -> void:
	var tower_info = GameManager.layout_node.get_node_or_null("Tower Info") if GameManager.layout_node else null
	for tower in get_tree().get_nodes_in_group("towers"):
		tower.set_selected(false)
	if tower_info:
		tower_info.hide_info()

func _on_game_over() -> void:
	var game_over_instance = game_over_scene.instantiate()
	var canvas = CanvasLayer.new()
	canvas.layer = 20
	get_tree().root.add_child(canvas)
	canvas.add_child(game_over_instance)
	if game_over_instance is Control:
		game_over_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().paused = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		PlacementManager.cancel()
		if WaveManager.is_running or GameManager.wave > 0:
			GameManager.save_wave_for_level(_level_path, GameManager.wave)
