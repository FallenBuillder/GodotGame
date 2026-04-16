extends Control

@onready var placement_mode_label = $Panel/PlacementModeLabel
@onready var auto_start_button = $Panel/AutoStartToggle

signal closed

func _ready() -> void:
	placement_mode_label.text = SettingsManager.get_placement_mode_name()
	_update_auto_start_button()

func _update_auto_start_button() -> void:
	auto_start_button.button_pressed = WaveManager.is_auto_start

func _on_back_pressed() -> void:
	closed.emit()
	queue_free()

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func _on_delete_data_pressed() -> void:
	ProgressManager.unlocked_levels = ["tutorial"]
	ProgressManager.unlocked_enemies = []
	ProgressManager.killed_enemy_counts = {}
	ProgressManager.beaten_levels = []
	ProgressManager.unlocked_towers = [1,2,3,4,5,6,7]
	ProgressManager.save_progress()
	var popup = AcceptDialog.new()
	popup.dialog_text = "All save data deleted."
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)

func _on_exit_button_pressed() -> void:
	_on_back_pressed()

func _on_prev_button_pressed() -> void:
	var current_mode = SettingsManager.placement_mode
	var new_mode = 0 if current_mode == 1 else 1
	SettingsManager.set_placement_mode(new_mode)
	placement_mode_label.text = SettingsManager.get_placement_mode_name()

func _on_next_button_pressed() -> void:
	var current_mode = SettingsManager.placement_mode
	var new_mode = 1 if current_mode == 0 else 0
	SettingsManager.set_placement_mode(new_mode)
	placement_mode_label.text = SettingsManager.get_placement_mode_name()

func _on_auto_start_toggled(toggled_on: bool) -> void:
	SettingsManager.set_auto_start(toggled_on)
	_update_auto_start_button()













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










func _on_unlock_all_button_pressed() -> void:
	for key in ProgressManager.LEVEL_ORDER:
		if key not in ProgressManager.unlocked_levels:
			ProgressManager.unlocked_levels.append(key)
		if key not in ["sandbox"] and key not in ProgressManager.beaten_levels:
			ProgressManager.beaten_levels.append(key)
	ProgressManager.save_progress()
	_refresh_buttons()


func _on_reset_levels_button_pressed() -> void:
	ProgressManager.unlocked_levels = ["tutorial"]
	ProgressManager.save_progress()
	_refresh_buttons()


func _on_congrats_button_pressed() -> void:
	var congrats = load("res://Game/Scenes/UI/Game UI/Congratulations/congratulations.tscn")
	if congrats:
		var canvas = CanvasLayer.new()
		canvas.layer = 10
		add_child(canvas)
		canvas.add_child(congrats.instantiate())
