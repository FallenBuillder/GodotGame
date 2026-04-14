extends Control

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	GameManager.restart_game()
	if get_parent() is CanvasLayer:
		get_parent().queue_free()
	else:
		queue_free()

func _on_back_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if get_parent() is CanvasLayer:
		get_parent().queue_free()
	get_tree().change_scene_to_file("res://Game/Scenes/UI/Menus/Main Menu/main_menu.tscn")
