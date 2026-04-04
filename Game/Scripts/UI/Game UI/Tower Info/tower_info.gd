extends CanvasLayer

@onready var tower_name_label = $Panel/VBoxContainer/TowerNameLabel
@onready var damage_label = $Panel/VBoxContainer/DamageLabel
@onready var sell_button = $Panel/VBoxContainer/SellButton
@onready var focus_mode_label = $Panel/VBoxContainer/FocusModeContainer/FocusModeLabel
@onready var prev_focus_button = $Panel/VBoxContainer/FocusModeContainer/PrevButton
@onready var next_focus_button = $Panel/VBoxContainer/FocusModeContainer/NextButton

var selected_tower = null
var current_tower: Node = null

func _ready() -> void:
	print("Tower Info UI ready!")
	hide()
	
	if not tower_name_label:
		push_error("TowerNameLabel not found!")
	if not damage_label:
		push_error("DamageLabel not found!")
	if not focus_mode_label:
		push_error("FocusModeLabel not found!")
	if not sell_button:
		push_error("SellButton not found!")
	
	sell_button.pressed.connect(_on_sell_pressed)
	prev_focus_button.pressed.connect(_on_prev_focus_pressed)
	next_focus_button.pressed.connect(_on_next_focus_pressed)
	
	print("Tower Info signals connected")

func show_tower_info(tower: Node) -> void:
	print("Showing info for tower: ", tower)
	selected_tower = tower
	current_tower = tower
	
	var tower_display_name = "Tower"
	if tower.has_method("get_tower_name"):
		tower_display_name = tower.get_tower_name()
	elif "tower_name" in tower:
		tower_display_name = tower.tower_name
	
	tower_name_label.text = tower_display_name
	damage_label.text = "Damage Dealt: " + str(tower.total_damage_dealt)
	focus_mode_label.text = tower.get_focus_mode_name()
	sell_button.text = "Sell ($" + str(tower.cost / 2) + ")"
	
	print("Tower info displayed, showing UI")
	show()

func hide_info() -> void:
	if selected_tower and is_instance_valid(selected_tower):
		if selected_tower.has_method("set_selected"):
			selected_tower.set_selected(false)
	
	selected_tower = null
	current_tower = null
	hide()

func update_damage_label(new_damage: int) -> void:
	if is_visible() and current_tower:
		damage_label.text = "Damage Dealt: " + str(new_damage)

func _on_sell_pressed() -> void:
	print("Sell button pressed")
	if not selected_tower or not is_instance_valid(selected_tower):
		print("No valid tower to sell")
		return
	
	var sell_amount = selected_tower.cost / 2
	print("Selling tower for: $", sell_amount)
	GameManager.add_money(sell_amount)
	selected_tower.queue_free()
	hide_info()

func _on_prev_focus_pressed() -> void:
	print("Previous focus pressed")
	if not selected_tower or not is_instance_valid(selected_tower):
		return
	
	var current_mode = selected_tower.focus_mode
	var new_mode = (current_mode - 1)
	if new_mode < 0:
		new_mode = 3
	
	selected_tower.set_focus_mode(new_mode)
	focus_mode_label.text = selected_tower.get_focus_mode_name()
	print("Focus mode changed to: ", focus_mode_label.text)

func _on_next_focus_pressed() -> void:
	print("Next focus pressed")
	if not selected_tower or not is_instance_valid(selected_tower):
		return
	
	var current_mode = selected_tower.focus_mode
	var new_mode = (current_mode + 1) % 4
	
	selected_tower.set_focus_mode(new_mode)
	focus_mode_label.text = selected_tower.get_focus_mode_name()
	print("Focus mode changed to: ", focus_mode_label.text)

func _input(event: InputEvent) -> void:
	if visible and event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			hide_info()
			get_viewport().set_input_as_handled()
