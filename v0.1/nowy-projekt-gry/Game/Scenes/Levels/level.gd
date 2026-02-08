extends Node2D
var enemy_scene = preload("res://Game/Scenes/Enemies/enemy.tscn")

func _ready() -> void:
	# Connect the button signal
	$SpawnButton.pressed.connect(_on_spawn_button_pressed)

func _on_spawn_button_pressed():
	spawn_enemy()

func spawn_enemy():
	var path_follow = PathFollow2D.new()
	var enemy = enemy_scene.instantiate()
	
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	
	$Path2D.add_child(path_follow)
