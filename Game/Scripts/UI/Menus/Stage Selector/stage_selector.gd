extends Control

signal closed

func _ready() -> void:
	_refresh_buttons()

func _refresh_buttons() -> void:
	var level_map = {
		"tutorial": "Tutorial",
		"level_1": "Level1",
		"level_2": "Level2",
		"level_3": "Level3",
		"level_4": "Level4",
		"level_5": "Level5",
		"sandbox": "DebugStage"
	}
	for key in level_map:
		var btn = get_node_or_null(level_map[key])
		if btn:
			var unlocked = ProgressManager.is_level_unlocked(key)
			btn.disabled = not unlocked
			btn.modulate = Color.WHITE if unlocked else Color(0.5, 0.5, 0.5, 1.0)

			var star = btn.get_node_or_null("StarIcon")
			if star:
				star.visible = ProgressManager.is_level_beaten(key)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func _on_congrats_pressed() -> void:
	var congrats = load("res://Game/Scenes/UI/Game UI/Congratulations/congratulations.tscn")
	if congrats:
		var canvas = CanvasLayer.new()
		canvas.layer = 10
		add_child(canvas)
		canvas.add_child(congrats.instantiate())

func _on_back_pressed() -> void:
	closed.emit()
	queue_free()

func _on_exit_button_pressed() -> void:
	_on_back_pressed()

func _on_unlock_all_pressed() -> void:
	for key in ProgressManager.LEVEL_ORDER:
		if key not in ProgressManager.unlocked_levels:
			ProgressManager.unlocked_levels.append(key)
		if key not in ["sandbox"] and key not in ProgressManager.beaten_levels:
			ProgressManager.beaten_levels.append(key)
	ProgressManager.save_progress()
	_refresh_buttons()

func _on_reset_levels_pressed() -> void:
	ProgressManager.unlocked_levels = ["tutorial"]
	ProgressManager.save_progress()
	_refresh_buttons()

func _load_level(path: String) -> void:
	var layout_scene = load("res://Game/Scenes/UI/Game UI/Game Layout/game_layout.tscn")
	var layout = layout_scene.instantiate()
	layout.level_path = path
	get_tree().root.add_child(layout)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = layout
	queue_free()

func _on_tutorial_pressed() -> void:
	_load_level("res://Game/Scenes/Levels/tutorial.tscn")

func _on_level_1_pressed() -> void:
	if ProgressManager.is_level_unlocked("level_1"):
		_load_level("res://Game/Scenes/Levels/level_1.tscn")

func _on_level_2_pressed() -> void:
	if ProgressManager.is_level_unlocked("level_2"):
		_load_level("res://Game/Scenes/Levels/level_2.tscn")

func _on_level_3_pressed() -> void:
	if ProgressManager.is_level_unlocked("level_3"):
		_load_level("res://Game/Scenes/Levels/level_3.tscn")

func _on_level_4_pressed() -> void:
	if ProgressManager.is_level_unlocked("level_4"):
		_load_level("res://Game/Scenes/Levels/level_4.tscn")

func _on_level_5_pressed() -> void:
	if ProgressManager.is_level_unlocked("level_5"):
		_load_level("res://Game/Scenes/Levels/level_5.tscn")

func _on_debug_stage_pressed() -> void:
	if ProgressManager.is_level_unlocked("sandbox"):
		_load_level("res://Game/Scenes/Levels/sandbox_level.tscn")
