extends Control

var settings_scene = preload("res://Game/Scenes/UI/Menus/Settings/settings.tscn")
var collections_scene = preload("res://Game/Scenes/UI/Menus/Collection/collections_menu.tscn")
var stages_scene = preload("res://Game/Scenes/UI/Menus/Stage Selector/stage_selector.tscn")
var popup_scene = preload("res://Game/Scenes/UI/Menus/Quit Warning/quit_warning.tscn")

@onready var panel = $TextureRect
@onready var title_label = $Title
@onready var overlay_layer = $OverlayLayer

func _ready() -> void:
	if GameManager.show_congratulations_on_menu:
		GameManager.show_congratulations_on_menu = false
		call_deferred("_show_congratulations")

func _show_congratulations() -> void:
	var congrats = load("res://Game/Scenes/UI/Game UI/Congratulations/congratulations.tscn")
	if congrats:
		var canvas = CanvasLayer.new()
		canvas.layer = 10
		add_child(canvas)
		canvas.add_child(congrats.instantiate())

func _dim(on: bool) -> void:
	var c = Color(0.4, 0.4, 0.4, 1.0) if on else Color(1, 1, 1, 1.0)
	panel.modulate = c
	title_label.modulate = c
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE if on else Control.MOUSE_FILTER_STOP

func _open_overlay(scene: PackedScene, on_closed: Callable = Callable()) -> void:
	for child in overlay_layer.get_children():
		child.queue_free()
	_dim(true)
	var instance = scene.instantiate()
	overlay_layer.add_child(instance)
	
	if instance.has_signal("closed"):
		instance.closed.connect(func():
			_dim(false)
			if on_closed.is_valid():
				on_closed.call()
		)

func _on_play_button_pressed() -> void:
	_open_overlay(stages_scene)

func _on_setting_button_pressed() -> void:
	_open_overlay(settings_scene)

func _on_collection_button_pressed() -> void:
	_open_overlay(collections_scene)

func _on_quit_button_pressed() -> void:
	_open_overlay(popup_scene)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_open_overlay(popup_scene)
