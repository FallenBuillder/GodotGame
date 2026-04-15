extends Control

@onready var placement_mode_label = $Panel/VBoxContainer/PlacementModeContainer/PlacementModeLabel
@onready var auto_start_button = $Panel/VBoxContainer/AutoStartContainer/AutoStartToggle

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
	ProgressManager.unlocked_towers = [1]
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
