extends Node

var fade_overlay: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_ui_layer()
	_create_logo_layer()

func _create_ui_layer() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 30
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	canvas.add_child(fade_overlay)
	#queue_free()
func _create_logo_layer() -> void:
	await fade_in(0)
	await get_tree().create_timer(1.0, false).timeout
	var logo = load("res://Game/Scenes/UI/Game UI/Logo/logo.tscn")
	if logo:
		var canvas = CanvasLayer.new()
		canvas.layer = 29
		add_child(canvas)
		canvas.add_child(logo.instantiate())
		SoundManager.play_constant("intro")
		await fade_out(0.5)
		await get_tree().create_timer(1.0, false).timeout
		await fade_in(1) # istnieje fade 
		canvas.queue_free()
		await get_tree().create_timer(1.0, false).timeout
		fade_out(2)
		
		
		
	
 


func fade_in(duration: float = 0.5) -> void:
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.tween_property(fade_overlay, "modulate:a", 1.0, duration).finished

func fade_out(duration: float = 0.5) -> void:
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.tween_property(fade_overlay, "modulate:a", 0.0, duration).finished

func _load_level(path: String) -> void:
	var layout_scene = load("res://Game/Scenes/UI/Game UI/Game Layout/game_layout.tscn")
	var layout = layout_scene.instantiate()
	layout.level_path = path
	get_tree().root.add_child(layout)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = layout
	#queue_free()

func transition_to_level(path: String) -> void:
	await fade_in(1)
	await get_tree().create_timer(1.0, false).timeout
	_load_level(path)
	await fade_out(1)
	#queue_free()
