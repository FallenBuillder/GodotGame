extends Node2D
var enemy_scene = preload("res://Game/Scenes/Enemies/enemy.tscn")
var home_menu_scene = preload("res://Game/Scenes/UI/HomeScreenUI/HomeScreen.tscn")

func _ready() -> void:
	# Connect the button signal
	$SpawnButton.pressed.connect(_on_spawn_button_pressed)
	$StartWaveButton.pressed.connect(_on_start_wave_button_pressed)
	WaveManager.setup_path($Path2D)
	
	# Displays The Start menu ( HomeScreenUI )
	var layer = CanvasLayer.new()
	add_child(layer)
	var screen_instance = home_menu_scene.instantiate()
	layer.add_child(screen_instance)
	if screen_instance is Control:
		screen_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().paused = true

func _on_spawn_button_pressed():
	spawn_enemy()

func _on_start_wave_button_pressed():
	start_wave_manager()

func spawn_enemy():
	var path_follow = PathFollow2D.new()
	var enemy = enemy_scene.instantiate()
	
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	
	$Path2D.add_child(path_follow)

func start_wave_manager():
	WaveManager.startWaveSystem()
