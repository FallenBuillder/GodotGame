extends Button

func _on_pressed() -> void:
	get_tree().paused = false
	var layer = get_parent().get_parent().get_parent()
	layer.queue_free()
