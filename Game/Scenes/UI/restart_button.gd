extends Button

func _on_pressed() -> void:
	get_parent().get_parent().hide()
	get_tree().paused = false
	get_tree().reload_current_scene() 
	#replace the line above with the line below in a case where we want to hide all the elements of the scene but not actually reset it 
	#GameManager.restart_game()
	
	
