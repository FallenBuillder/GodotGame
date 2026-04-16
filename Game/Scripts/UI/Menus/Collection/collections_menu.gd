extends Control

@onready var exit_button = $Panel/ExitButton
@onready var mice_button = $Panel/MiceButton
@onready var cheeses_button = $Panel/CheesesButton
@onready var towers_grid = $Panel/VBoxContainer/MiceGrid
@onready var enemies_grid = $Panel/VBoxContainer/CheesesGrid

var tower_info_scene = preload("res://Game/Scenes/UI/Menus/Collection/collection_tower_info.tscn")
var enemy_info_scene = preload("res://Game/Scenes/UI/Menus/Collection/collection_enemy_info.tscn")
var _active_info: Control = null
var _overlay: ColorRect = null

var tower_database: Dictionary = {}
var enemy_database: Dictionary = {}

const DAMAGE_TYPE_NAMES := {0: "Basic", 1: "Explosion", 2: "Freeze"}

signal closed

func _ready() -> void:
	exit_button.pressed.connect(_on_exit_pressed)
	mice_button.pressed.connect(_show_towers)
	cheeses_button.pressed.connect(_show_enemies)
	_load_databases()
	_populate_towers()
	_populate_enemies()
	_show_towers()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if _active_info and is_instance_valid(_active_info):
			_close_info()
		else:
			_on_exit_pressed()

func _load_databases() -> void:
	CollectionData.ensure_built()
	_load_tower_database()
	_load_enemy_database()

func _load_tower_database() -> void:
	tower_database = CollectionData.towers.duplicate(true)
	for tid in tower_database:
		tower_database[tid]["unlocked"] = tid in ProgressManager.unlocked_towers

func _load_enemy_database() -> void:
	enemy_database = CollectionData.enemies.duplicate(true)
	for eid in enemy_database:
		var data = enemy_database[eid]
		data["unlocked"] = eid in ProgressManager.unlocked_enemies
		data["killed"] = ProgressManager.killed_enemy_counts.get(eid, 0)

func _immunity_names(immunities: Array) -> Array:
	var names := []
	var map := {0: "Basic", 1: "Explosion", 2: "Freeze"}
	for i in immunities:
		names.append(map.get(i, "Unknown"))
	return names

func _populate_towers() -> void:
	var sorted_ids = tower_database.keys()
	sorted_ids.sort()
	for tid in sorted_ids:
		_create_tower_button(tower_database[tid])
	#_add_tower_debug_buttons()

func _populate_enemies() -> void:
	var sorted_ids = enemy_database.keys()
	sorted_ids.sort()
	for eid in sorted_ids:
		_create_enemy_button(enemy_database[eid])
	#_add_enemy_debug_buttons()

func _create_tower_button(tower_data: Dictionary) -> void:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(150, 180)

	var button = TextureButton.new()
	button.custom_minimum_size = Vector2(128, 128)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = tower_data.sprite
	if not tower_data.unlocked:
		button.modulate = Color(0, 0, 0, 1)
	button.pressed.connect(_on_tower_button_pressed.bind(tower_data))

	var label = Label.new()
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = tower_data.name if tower_data.unlocked else "???"
	container.add_child(button)
	container.add_child(label)
	towers_grid.add_child(container)

func _create_enemy_button(enemy_data: Dictionary) -> void:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(150, 180)

	var is_unlocked = enemy_data.get("unlocked", false)
	var kill_count = enemy_data.get("killed", 0)

	var button = TextureButton.new()
	button.custom_minimum_size = Vector2(128, 128)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = enemy_data.sprite
	if not is_unlocked:
		button.modulate = Color.BLACK
	button.pressed.connect(_on_enemy_button_pressed.bind(enemy_data))

	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = (enemy_data.name + "\nKilled: " + str(kill_count)) if is_unlocked else "???"

	container.add_child(button)
	container.add_child(label)
	enemies_grid.add_child(container)

"""
func _add_tower_debug_buttons() -> void:
		for tid in tower_database:
			if tid not in ProgressManager.unlocked_towers:
				ProgressManager.unlocked_towers.append(tid) 
		ProgressManager.save_progress()
		_reload_towers()

		ProgressManager.unlocked_towers = [1]
		ProgressManager.save_progress()
		_reload_towers()


func _add_enemy_debug_buttons() -> void:
	var hbox = HBoxContainer.new()
	hbox.name = "EnemyDebugButtons"

	var unlock_btn = Button.new()
	unlock_btn.text = "Unlock All"
	unlock_btn.pressed.connect(func():
		for eid in enemy_database:
			if eid not in ProgressManager.unlocked_enemies:
				ProgressManager.unlocked_enemies.append(eid)
		ProgressManager.save_progress()
		_reload_enemies()
	)

	var reset_btn = Button.new()
	reset_btn.text = "Lock All"
	reset_btn.pressed.connect(func():
		ProgressManager.unlocked_enemies.clear()
		ProgressManager.killed_enemy_counts.clear()
		ProgressManager.save_progress()
		_reload_enemies()
	)
	

	hbox.add_child(unlock_btn)
	hbox.add_child(reset_btn)
	enemies_grid.add_child(hbox)
	enemies_grid.move_child(hbox, 0)
"""

func _reload_towers() -> void:
	for child in towers_grid.get_children():
		child.queue_free()
	_load_tower_database()
	_populate_towers()

func _reload_enemies() -> void:
	for child in enemies_grid.get_children():
		child.queue_free()
	_load_enemy_database()
	_populate_enemies()

func _on_tower_button_pressed(tower_data: Dictionary) -> void:
	if not tower_data.get("unlocked", true):
		_show_locked_tower_popup()
		return
	_open_info(tower_info_scene, tower_data)

func _show_locked_tower_popup() -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = "This tower is locked!"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)

func _on_enemy_button_pressed(enemy_data: Dictionary) -> void:
	if not enemy_data.get("unlocked", false):
		_show_locked_popup()
		return
	_open_info(enemy_info_scene, enemy_data)

func _open_info(scene: PackedScene, data: Dictionary) -> void:
	if _active_info and is_instance_valid(_active_info):
		_active_info.queue_free()
	if _overlay and is_instance_valid(_overlay):
		_overlay.queue_free()

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.5)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	_active_info = scene.instantiate()
	add_child(_active_info)
	_active_info.populate(data)

	if _active_info.has_signal("closed"):
		_active_info.closed.connect(_close_info)
	elif _active_info.has_method("get_close_button"):
		pass

func _close_info() -> void:
	if _active_info and is_instance_valid(_active_info):
		_active_info.queue_free()
	if _overlay and is_instance_valid(_overlay):
		_overlay.queue_free()
	_active_info = null
	_overlay = null

func _show_locked_popup() -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = "You haven't seen this enemy yet!"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)

func _show_towers() -> void:
	towers_grid.show()
	enemies_grid.hide()

func _show_enemies() -> void:
	towers_grid.hide()
	enemies_grid.show()

func _on_exit_pressed() -> void:
	closed.emit()
	queue_free()
