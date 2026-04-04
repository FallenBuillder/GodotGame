extends Node2D

var game_over_scene = preload("res://Game/Scenes/UI/Game UI/Game Over/game_over.tscn")
var game_over_instance = null
var settings_scene = preload("res://Game/Scenes/UI/Game UI/Game Menu/game_menu.tscn")

var enemy_scene_number := 1

func _ready() -> void:
	WaveManager.setup_path($Path2D)
	GameManager.level_node = self
	GameManager.game_over.connect(_on_game_over)

	var ui_instance = preload("res://Game/Scenes/UI/Game UI/General UI/game_ui.tscn").instantiate()
	add_child(ui_instance)
	GameManager.ui = ui_instance

func spawn_enemy():
	var path_follow = PathFollow2D.new()
	
	var dir = "res://Game/Scenes/enemies/"
	var files = DirAccess.open(dir).get_files()
	var scene_file := ""
	for f in files:
		if f.begins_with(str(enemy_scene_number) + "_") and f.ends_with(".tscn"):
			scene_file = f
			break
	
	if scene_file == "":
		print("No enemy scene found for number: ", enemy_scene_number)
		return
	
	var enemy_scene = load(dir + scene_file)
	var enemy = enemy_scene.instantiate()
	
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	$Path2D.add_child(path_follow)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var settings = settings_scene.instantiate()
		add_child(settings)
		get_tree().paused = true
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_viewport().gui_get_hovered_control() != null:
			return
		
		var clicked_tower = false
		
		for tower in get_tree().get_nodes_in_group("towers"):
			if tower.is_hovered:
				clicked_tower = true
				break
		
		if not clicked_tower:
			deselect_all_towers()

func deselect_all_towers():
	var tower_info = get_node_or_null("Tower Info")
	
	for tower in get_tree().get_nodes_in_group("towers"):
		tower.set_selected(false)
		
		if tower_info:
			tower_info.hide_info()

func _on_game_over():
	if GameManager.ui:
		game_over_instance = game_over_scene.instantiate()
		GameManager.ui.add_child(game_over_instance)

		if game_over_instance is Control:
			game_over_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().paused = true
