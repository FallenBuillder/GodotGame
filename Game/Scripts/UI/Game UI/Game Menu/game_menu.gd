extends CanvasLayer

var popup_scene = preload("res://Game/Scenes/UI/Menus/Quit Warning/quit_warning.tscn")
var settings_scene = preload("res://Game/Scenes/UI/Menus/Settings/settings.tscn")

@onready var panel = $Panel

signal closed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
		get_tree().paused = false

func _on_back_pressed():
	closed.emit()
	queue_free()

func _on_return_button_pressed() -> void:
	_on_back_pressed()
	get_tree().paused = false

func _on_reset_button_pressed() -> void:
	get_tree().paused = false
	GameManager.restart_game()
	queue_free()

func _on_exit_button_pressed() -> void:
	get_viewport().set_input_as_handled()
	panel.modulate = Color(0.4, 0.4, 0.4, 1.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var popup = popup_scene.instantiate()
	popup.from_game_menu = true
	add_child(popup)
	
	popup.closed.connect(func():
		panel.modulate = Color(1, 1, 1 ,1.0)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
	)


func _on_settings_button_pressed() -> void:
	panel.modulate = Color(0.4, 0.4, 0.4, 1.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var settings = settings_scene.instantiate()
	add_child(settings)
	
	settings.closed.connect(func():
		panel.modulate = Color(1, 1, 1 ,1.0)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
	)
