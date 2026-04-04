extends Control

var from_game_menu = false

signal closed

func _on_return_button_pressed() -> void:
	closed.emit()
	queue_free()

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	
	if from_game_menu:
		get_tree().change_scene_to_file("res://Game/Scenes/UI/Menus/Main Menu/main_menu.tscn")
	else:
		get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_return_button_pressed()
		get_tree().paused = false

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered == self:
			closed.emit()
			queue_free()
