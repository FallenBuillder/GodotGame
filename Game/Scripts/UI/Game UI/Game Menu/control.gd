extends Control

signal closed

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered == self:
			close_menu()

func close_menu():
	closed.emit()
	get_tree().paused = false
	get_parent().queue_free()
