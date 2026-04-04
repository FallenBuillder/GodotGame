extends Node2D

const STARTING_MONEY = 9999999
const STARTING_HEALTH = 9999999

func _ready() -> void:
	GameManager.money = STARTING_MONEY
	GameManager.health = STARTING_HEALTH
	GameManager.money_changed.emit(GameManager.money)
	GameManager.health_changed.emit(GameManager.health)
	
	WaveManager.setup_path($Path2D)
	GameManager.level_node = self
	GameManager.game_over.connect(_on_game_over)

func spawn_enemy() -> void:
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

var enemy_scene_number := 1

func _process(_delta: float) -> void:
	if GameManager.health <= 0:
		GameManager.health = 1

func _on_game_over() -> void:
	pass
