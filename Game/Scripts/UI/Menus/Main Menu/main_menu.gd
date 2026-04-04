extends Control

var settings_scene = preload("res://Game/Scenes/UI/Menus/Settings/settings.tscn")
var collections_scene = preload("res://Game/Scenes/UI/Menus/Collection/collections_menu.tscn")
var stages_scene = preload("res://Game/Scenes/UI/Menus/Stage Selector/stage_selector.tscn")
var popup_scene = preload("res://Game/Scenes/UI/Menus/Quit Warning/quit_warning.tscn")

@onready var panel = $Panel

func _on_play_button_pressed() -> void:
	panel.modulate = Color(0.4, 0.4, 0.4, 1.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var stages = stages_scene.instantiate()
	add_child(stages)
	
	stages.closed.connect(func():
		panel.modulate = Color(1, 1, 1 ,1.0)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
	)

func _on_setting_button_pressed() -> void:
	panel.modulate = Color(0.4, 0.4, 0.4, 1.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var settings = settings_scene.instantiate()
	add_child(settings)
	
	settings.closed.connect(func():
		panel.modulate = Color(1, 1, 1 ,1.0)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
	)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		panel.modulate = Color(0.4, 0.4, 0.4, 1.0)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
		var popup = popup_scene.instantiate()
		add_child(popup)
	
		popup.closed.connect(func():
			panel.modulate = Color(1, 1, 1 ,1.0)
			panel.mouse_filter = Control.MOUSE_FILTER_STOP
		)

func _on_collection_button_pressed() -> void:
	panel.modulate = Color(0.4, 0.4, 0.4, 1.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var collections = collections_scene.instantiate()
	add_child(collections)
	
	collections.closed.connect(func():
		panel.modulate = Color(1, 1, 1 ,1.0)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
	)

func _on_quit_button_pressed() -> void:
	get_viewport().set_input_as_handled()
	panel.modulate = Color(0.4, 0.4, 0.4, 1.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var popup = popup_scene.instantiate()
	add_child(popup)
	
	popup.closed.connect(func():
		panel.modulate = Color(1, 1, 1 ,1.0)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
	)
