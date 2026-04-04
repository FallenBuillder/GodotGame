extends Control

@onready var exit_button = $Panel/VBoxContainer/TopButtons/ExitButton
@onready var mice_button = $Panel/VBoxContainer/TopButtons/MiceButton
@onready var cheeses_button = $Panel/VBoxContainer/TopButtons/CheesesButton
@onready var towers_grid = $Panel/VBoxContainer/TowersGrid
@onready var enemies_grid = $Panel/VBoxContainer/EnemiesGrid
@onready var info_popup = $InfoPopup

var tower_database: Dictionary = {}
var enemy_database: Dictionary = {}

func _ready() -> void:
	exit_button.pressed.connect(_on_exit_pressed)
	mice_button.pressed.connect(_show_towers)
	cheeses_button.pressed.connect(_show_enemies)
	
	_load_databases()
	_populate_towers()
	_populate_enemies()
	
	_show_towers()
	
	info_popup.hide()

func _load_databases() -> void:
	_load_tower_database()
	_load_enemy_database()

func _load_tower_database() -> void:
	var towers_dir = "res://Game/Scenes/Towers/"
	var dir = DirAccess.open(towers_dir)
	if not dir:
		return
	
	var files = dir.get_files()
	for file in files:
		if not file.ends_with(".tscn"):
			continue
		
		var scene_path = towers_dir + file
		var tower_scene = load(scene_path)
		if not tower_scene:
			continue
		
		var tower = tower_scene.instantiate()
		
		var tower_data = {
			"scene_path": scene_path,
			"id": tower.get("tower_id") if "tower_id" in tower else 0,
			"name": tower.get("tower_name") if "tower_name" in tower else "Tower",
			"unlocked": tower.get("unlocked") if "unlocked" in tower else true,
			"sprite": _get_sprite_texture(tower),
			"damage": tower.get("damage") if "damage" in tower else 0,
			"range": tower.get("detection_range") if "detection_range" in tower else 0,
			"fire_rate": tower.get("fire_rate") if "fire_rate" in tower else 0,
			"cost": tower.get("cost") if "cost" in tower else 0,
		}
		
		tower_database[tower_data.id] = tower_data
		tower.queue_free()

func _load_enemy_database() -> void:
	var enemies_dir = "res://Game/Scenes/enemies/"
	var dir = DirAccess.open(enemies_dir)
	if not dir:
		return
	
	var files = dir.get_files()
	for file in files:
		if not file.ends_with(".tscn"):
			continue
		
		if "_regrow" in file or "_camo" in file:
			continue
		
		var scene_path = enemies_dir + file
		var enemy_scene = load(scene_path)
		if not enemy_scene:
			continue
		
		var enemy = enemy_scene.instantiate()
		
		var enemy_data = {
			"scene_path": scene_path,
			"id": enemy.get("enemy_id") if "enemy_id" in enemy else 0,
			"name": enemy.get("enemy_name") if "enemy_name" in enemy else "Enemy",
			"unlocked": enemy.get("unlocked") if "unlocked" in enemy else true,
			"sprite": _get_sprite_texture(enemy),
			"health": enemy.get("max_health") if "max_health" in enemy else 0,
			"speed": enemy.get("speed") if "speed" in enemy else 0,
			"damage": enemy.get("damage") if "damage" in enemy else 0,
			"reward": enemy.get("reward") if "reward" in enemy else 0,
			"can_heal": enemy.get("can_heal") if "can_heal" in enemy else false,
		}
		
		enemy_database[enemy_data.id] = enemy_data
		enemy.queue_free()

func _get_sprite_texture(node: Node) -> Texture2D:
	if node.has_node("Sprite2D"):
		return node.get_node("Sprite2D").texture
	return null

func _populate_towers() -> void:
	var sorted_ids = tower_database.keys()
	sorted_ids.sort()
	
	for tower_id in sorted_ids:
		var data = tower_database[tower_id]
		_create_tower_button(data)

func _populate_enemies() -> void:
	var sorted_ids = enemy_database.keys()
	sorted_ids.sort()
	
	for enemy_id in sorted_ids:
		var data = enemy_database[enemy_id]
		_create_enemy_button(data)

func _create_tower_button(tower_data: Dictionary) -> void:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(150, 180)
	
	var button = TextureButton.new()
	button.custom_minimum_size = Vector2(128, 128)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	if tower_data.unlocked:
		button.texture_normal = tower_data.sprite
	else:
		button.texture_normal = tower_data.sprite
		button.modulate = Color.BLACK
	
	button.pressed.connect(_on_tower_button_pressed.bind(tower_data))
	
	var label = Label.new()
	label.text = tower_data.name if tower_data.unlocked else "???"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	container.add_child(button)
	container.add_child(label)
	towers_grid.add_child(container)

func _create_enemy_button(enemy_data: Dictionary) -> void:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(150, 180)
	
	var button = TextureButton.new()
	button.custom_minimum_size = Vector2(128, 128)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	if enemy_data.unlocked:
		button.texture_normal = enemy_data.sprite
	else:
		button.texture_normal = enemy_data.sprite
		button.modulate = Color.BLACK
	
	button.pressed.connect(_on_enemy_button_pressed.bind(enemy_data))
	
	var label = Label.new()
	label.text = enemy_data.name if enemy_data.unlocked else "???"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	container.add_child(button)
	container.add_child(label)
	enemies_grid.add_child(container)

func _on_tower_button_pressed(tower_data: Dictionary) -> void:
	if not tower_data.unlocked:
		_show_locked_popup()
		return
	
	info_popup.show_tower_info(tower_data)
	info_popup.show()

func _on_enemy_button_pressed(enemy_data: Dictionary) -> void:
	if not enemy_data.unlocked:
		_show_locked_popup()
		return
	
	info_popup.show_enemy_info(enemy_data)
	info_popup.show()

func _show_locked_popup() -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = "You haven't seen/unlocked this yet!"
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
	get_tree().quit()
