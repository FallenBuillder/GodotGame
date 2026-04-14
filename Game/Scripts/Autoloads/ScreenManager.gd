extends CanvasLayer

const REF_W := 1920.0
const REF_H := 1080.0

var left_bar: ColorRect
var right_bar: ColorRect

func _ready() -> void:
	layer = 1

	left_bar = ColorRect.new()
	left_bar.color = Color(0, 0, 0, 1)
	left_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_bar)

	right_bar = ColorRect.new()
	right_bar.color = Color(0, 0, 0, 1)
	right_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(right_bar)

	get_viewport().size_changed.connect(_update_bars)
	_update_bars()

func _update_bars() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var vp_aspect = vp_size.x / vp_size.y
	var ref_aspect = REF_W / REF_H

	if vp_aspect > ref_aspect:
		var bar_w = (vp_size.x - vp_size.y * ref_aspect) * 0.5
		left_bar.size = Vector2(bar_w, vp_size.y)
		left_bar.position = Vector2.ZERO
		right_bar.size = Vector2(bar_w, vp_size.y)
		right_bar.position = Vector2(vp_size.x - bar_w, 0.0)
	else:
		var bar_h = (vp_size.y - vp_size.x / ref_aspect) * 0.5
		left_bar.size = Vector2(vp_size.x, bar_h)
		left_bar.position = Vector2.ZERO
		right_bar.size = Vector2(vp_size.x, bar_h)
		right_bar.position = Vector2(0.0, vp_size.y - bar_h)
