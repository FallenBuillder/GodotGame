extends Panel


func _on_speed_up_button_pressed() -> void:
	if is_sandbox:
		GameManager.speed_up()
		_set_button_state(ButtonState.SPEED_UP)
		return
	match _button_state:
		ButtonState.START_WAVE:
			_set_button_state(ButtonState.SPEED_UP)
			WaveManager.start_wave(_next_wave_number)
			if _was_fast_before_eave_end:
				_was_fast_before_eave_end = false
				GameManager.set_speed(true)
		ButtonState.SPEED_UP:
			GameManager.speed_up()
			_set_button_state(ButtonState.SPEED_UP)
