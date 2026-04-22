extends Control

func _on_return_button_pressed() -> void :
    get_tree().paused = false
    Engine.time_scale = 1.0
    get_tree().change_scene_to_file("res://Game/Scenes/UI/Menus/Main Menu/main_menu.tscn")
