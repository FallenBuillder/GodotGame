extends Control

signal closed

func _on_back_pressed():
	closed.emit()
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func _on_exit_button_pressed() -> void:
	_on_back_pressed()

func _on_tutorial_pressed() -> void:
	pass

func _on_debug_stage_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Scenes/Levels/sandbox_level.tscn")

func _on_level_1_pressed() -> void:
	pass # Replace with function body.

func _on_level_2_pressed() -> void:
	pass # Replace with function body.

func _on_level_3_pressed() -> void:
	pass # Replace with function body.

func _on_level_4_pressed() -> void:
	pass # Replace with function body.

func _on_level_5_pressed() -> void:
	pass # Replace with function body.
