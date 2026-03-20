extends Node
var enemy_scene = preload("res://Game/Scenes/Enemies/enemy.tscn")
var current_path: Path2D

func setup_path(path_node: Path2D):
	current_path = path_node

func startWaveSystem():
	GameManager.change_wave(1)
	print("Current Wave: ", GameManager.wave) # just some debug
	
	var CurrentWave = GameManager.wave
	for b in range(CurrentWave):
		for i in range(3):
			var path_follow = PathFollow2D.new()
			var enemy = enemy_scene.instantiate()
	
			enemy.setup(path_follow)
			path_follow.add_child(enemy)
			current_path.add_child(path_follow)
			
			#Interval
			await get_tree().create_timer(0.5).timeout

#This is a very basic version of the wave system just for the proof of concept. I will be adding a complex one soon..
