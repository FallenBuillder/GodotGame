extends Control

@onready var placement_mode_label = $VBoxContainer/PlacementModeContainer/PlacementModeLabel
@onready var auto_start_button = $VBoxContainer/AutoStartContainer/AutoStartToggle

signal closed

func _ready() -> void:
	placement_mode_label.text = SettingsManager.get_placement_mode_name()
	_update_auto_start_button()

func _update_auto_start_button() -> void:
	auto_start_button.button_pressed = GameManager.auto_start

func _on_back_pressed() -> void:
	closed.emit()
	queue_free()

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

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
