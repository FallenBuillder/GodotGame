extends CanvasLayer

var settings_scene = preload("res://Game/Scenes/UI/Menus/Settings/settings.tscn")

@onready var money_label = $UILabelsContainer/MoneyLabel
@onready var health_label = $UILabelsContainer/HealthLabel
@onready var wave_label = $UILabelsContainer/WaveLabel
@onready var money_input = $DebugOptinonsContainer/MoneyAmount
@onready var health_input = $DebugOptinonsContainer/HealthAmount
@onready var wave_input = $DebugOptinonsContainer/WaveContainer/WaveAmount
@onready var speed_up_button = $UIButtonsContainer/SpeedUpButton

enum ButtonState { START_WAVE, SPEED_UP, WAITING }
var _button_state := ButtonState.START_WAVE
var _next_wave_number := 1

func _ready() -> void:
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.wave_changed.connect(_on_wave_changed)

	WaveManager.wave_completed.connect(_on_wave_completed)
	WaveManager.wave_started.connect(_on_wave_started)
	WaveManager.all_waves_completed.connect(_on_all_waves_completed)

	update_money_display(GameManager.money)
	update_health_display(GameManager.health)
	update_wave_display(GameManager.wave)

	money_input.max_length = 6
	health_input.max_length = 6
	wave_input.max_length = 3

	_set_button_state(ButtonState.START_WAVE)

func _set_button_state(state: ButtonState) -> void:
	_button_state = state
	match state:
		ButtonState.START_WAVE:
			speed_up_button.text = "Start Wave " + str(_next_wave_number)
			speed_up_button.disabled = false
		ButtonState.SPEED_UP:
			speed_up_button.text = "Speed Up" if not GameManager.is_fast else "Normal Speed"
			speed_up_button.disabled = false
		ButtonState.WAITING:
			speed_up_button.text = "Wave " + str(GameManager.wave) + " in progress"
			speed_up_button.disabled = true

func _on_speed_up_button_pressed() -> void:
	match _button_state:
		ButtonState.START_WAVE:
			WaveManager.start_wave(_next_wave_number)
		ButtonState.SPEED_UP:
			GameManager.speed_up()
			_set_button_state(ButtonState.SPEED_UP)

func _on_wave_started(_wave_num: int) -> void:
	_set_button_state(ButtonState.SPEED_UP)

func _on_wave_completed(wave_num: int) -> void:
	if GameManager.is_fast:
		GameManager.set_speed(false)

	_next_wave_number = wave_num + 1

	if GameManager.auto_start and _next_wave_number <= WaveManager.get_total_waves():
		_set_button_state(ButtonState.SPEED_UP)
		WaveManager.start_wave(_next_wave_number)
	elif _next_wave_number <= WaveManager.get_total_waves():
		_set_button_state(ButtonState.START_WAVE)
	else:
		speed_up_button.text = "All Waves Done!"
		speed_up_button.disabled = true

func _on_all_waves_completed() -> void:
	speed_up_button.text = "Victory!"
	speed_up_button.disabled = true

func _on_start_wave_button_pressed() -> void:
	WaveManager.start_wave(_next_wave_number)

func _on_lose_button_pressed() -> void:
	GameManager.lose_game()

func _on_toggle_path_pressed() -> void:
	var path_node = get_tree().current_scene.get_node_or_null("Path2D")
	if not path_node:
		push_warning("Path2D node not found in scene")
		return
	path_node.show_path = not path_node.show_path
	path_node.queue_redraw()

func _on_settings_button_pressed() -> void:
	var settings = settings_scene.instantiate()
	add_child(settings)
	visible = false
	if settings.has_signal("closed"):
		settings.closed.connect(_on_settings_closed)
	get_tree().paused = true

func _on_settings_closed() -> void:
	visible = true

func _on_money_changed(new_amount: int) -> void:
	update_money_display(new_amount)

func _on_health_changed(new_amount: int) -> void:
	update_health_display(new_amount)

func _on_wave_changed(new_amount: int) -> void:
	update_wave_display(new_amount)

func update_money_display(amount: int) -> void:
	money_label.text = "Money: $" + str(amount)

func update_health_display(amount: int) -> void:
	health_label.text = "Health: " + str(amount)

func update_wave_display(amount: int) -> void:
	wave_label.text = "Wave: " + str(amount)

func _on_money_amount_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int():
		GameManager.add_money(int(new_text))
	money_input.text = ""

func _on_health_amount_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int():
		GameManager.add_health(int(new_text))
	health_input.text = ""

func _on_wave_amount_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int():
		GameManager.change_wave(int(new_text))
	wave_input.text = ""

func _on_spawn_enemy_text_submitted(new_text: String) -> void:
	new_text = new_text.strip_edges()
	if not new_text.is_valid_int():
		push_warning("Invalid enemy number: ", new_text)
		return
	var number = int(new_text)
	if not GameManager.level_node:
		push_warning("Level node not found")
		return
	GameManager.level_node.enemy_scene_number = number
	GameManager.level_node.spawn_enemy()
