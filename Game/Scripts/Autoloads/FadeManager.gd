extends Node

var fade_overlay: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_ui_layer()

func _create_ui_layer() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 128
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(fade_overlay)

func fade_in(duration: float = 0.5) -> void:
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.tween_property(fade_overlay, "modulate:a", 1.0, duration).finished

func fade_out(duration: float = 0.5) -> void:
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_overlay, "modulate:a", 0.0, duration)
	await tween.finished
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func transition_to_level(path: String) -> void:
	await fade_in(0.5)
	get_tree().paused = true
	await get_tree().create_timer(1.0, false).timeout
	get_tree().change_scene_to_file(path)
	get_tree().paused = false
	await fade_out(0.5)
