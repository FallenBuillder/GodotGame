extends Node

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

var current_path: Path2D
var is_running := false
var _enemies_alive := 0
var _wave_spawning := false
var _total_waves := 85

var WAVE_DATA: Array = []

func _ready() -> void:
	_build_wave_data()

func setup_path(path_node: Path2D) -> void:
	current_path = path_node

func get_total_waves() -> int:
	return _total_waves

func start_wave(wave_number: int) -> void:
	if is_running:
		return
	if wave_number < 1 or wave_number > _total_waves:
		return

	is_running = true
	_wave_spawning = true
	_enemies_alive = 0

	GameManager.change_wave(wave_number)
	wave_started.emit(wave_number)

	var groups: Array = WAVE_DATA[wave_number - 1]
	await _run_wave_groups(groups)

	_wave_spawning = false
	_check_wave_done(wave_number)

func reset() -> void:
	is_running = false
	_wave_spawning = false
	_enemies_alive = 0
	if current_path:
		for child in current_path.get_children():
			if child.name != "PathBlocker":
				child.queue_free()

func on_enemy_removed() -> void:
	_enemies_alive -= 1
	if _enemies_alive < 0:
		_enemies_alive = 0
	if not _wave_spawning:
		_check_wave_done(GameManager.wave)

func _check_wave_done(wave_number: int) -> void:
	if _enemies_alive <= 0 and not _wave_spawning and is_running:
		is_running = false
		var reward = 100 + (wave_number - 1)
		GameManager.add_money(reward)
		wave_completed.emit(wave_number)
		if wave_number >= _total_waves:
			all_waves_completed.emit()

func _run_wave_groups(groups: Array) -> void:
	var max_time := 0.0
	for g in groups:
		var end_t: float = g["end"] if g["end"] > g["start"] else g["start"] + 0.1
		if end_t > max_time:
			max_time = end_t

	for g in groups:
		_spawn_group_delayed(g)

	await get_tree().create_timer(max_time).timeout

func _spawn_group_delayed(group: Dictionary) -> void:
	var start_t: float = group["start"]
	var end_t: float = group["end"]
	var count: int = group["count"]
	var enemy_id: int = group["enemy_id"]
	var camo: bool = group.get("camo", false)
	var regen: bool = group.get("regen", false)

	if start_t > 0.0:
		await get_tree().create_timer(start_t).timeout

	var duration: float = max(end_t - start_t, 0.0)
	var interval: float = duration / float(max(count, 1))

	for i in range(count):
		if not is_running:
			return
		_spawn_enemy(enemy_id, camo, regen)
		if i < count - 1 and interval > 0.0:
			await get_tree().create_timer(interval).timeout

func _spawn_enemy(enemy_id: int, camo: bool, regen: bool) -> void:
	if not current_path:
		return

	var dir := "res://Game/Scenes/enemies/"
	var scene_file := ""

	var candidates := []
	if camo and regen:
		candidates.append(str(enemy_id) + "_basic_enemy_camo_regen.tscn")
		candidates.append(str(enemy_id) + "_basic_enemy_camo.tscn")
		candidates.append(str(enemy_id) + "_basic_enemy_regen.tscn")
	elif camo:
		candidates.append(str(enemy_id) + "_basic_enemy_camo.tscn")
	elif regen:
		candidates.append(str(enemy_id) + "_basic_enemy_regen.tscn")
		candidates.append(str(enemy_id) + "_basic_enemy_regrow.tscn")

	var files = DirAccess.open(dir).get_files()
	for candidate in candidates:
		for f in files:
			if f == candidate:
				scene_file = f
				break
		if scene_file != "":
			break

	if scene_file == "":
		for f in files:
			if f.begins_with(str(enemy_id) + "_") and f.ends_with(".tscn"):
				scene_file = f
				break

	if scene_file == "":
		push_warning("WaveManager: no scene for enemy_id " + str(enemy_id))
		return

	var enemy_scene = load(dir + scene_file)
	var path_follow = PathFollow2D.new()
	var enemy = enemy_scene.instantiate()

	if camo and enemy.has_method("set_camo"):
		enemy.set_camo(true)
	if regen and enemy.has_method("set_regen"):
		enemy.set_regen(true)

	var _already_counted := false
	enemy.tree_exited.connect(func():
		if not _already_counted:
			_already_counted = true
			on_enemy_removed()
	)

	_enemies_alive += 1
	enemy.setup(path_follow)
	path_follow.add_child(enemy)
	current_path.add_child(path_follow)

func _g(start: float, end: float, eid: int, count: int,
		camo: bool = false, regen: bool = false) -> Dictionary:
	return {"start": start, "end": end, "enemy_id": eid,
			"count": count, "camo": camo, "regen": regen}

func _build_wave_data() -> void:
	WAVE_DATA = []
	# Round 1
	WAVE_DATA.append([_g(0,17.5125,1,20)])
	# Round 2
	WAVE_DATA.append([_g(0,16.559,1,30)])
	# Round 3
	WAVE_DATA.append([_g(0,5.139,1,10),_g(5.71,7.994,2,5),_g(8.565,13.704,1,10)])
	# Round 4
	WAVE_DATA.append([_g(0,10.849,1,20),_g(11.42,19.414,2,15),_g(19.985,22.8725,1,10)])
	# Round 5
	WAVE_DATA.append([_g(0,5.139,2,10),_g(5.71,7.994,1,5),_g(8.565,16.559,2,15)])
	# Round 6
	WAVE_DATA.append([_g(0,1.713,3,4),_g(2.284,10.278,1,15),_g(10.849,20.843,2,15)])
	# Round 7
	WAVE_DATA.append([_g(0,5.14,2,10),_g(5.71,10.66,3,5),_g(11.8125,22.6625,1,20),_g(22.82,26.812,2,15)])
	# Round 8
	WAVE_DATA.append([_g(0,10.85,2,20),_g(11.42,11.99,3,2),_g(12.562,14.532,1,10),_g(18.272,28.922,3,12)])
	# Round 9
	WAVE_DATA.append([_g(0,18.957,3,30)])
	# Round 10
	WAVE_DATA.append([_g(0,35,2,60),_g(35,44,2,20),_g(44,48,2,22)])
	# Round 11
	WAVE_DATA.append([_g(0,0.571,4,2),_g(3.8,10.081,3,12),_g(10.24,14.044,2,10),_g(13.62,18.195,1,10)])
	# Round 12
	WAVE_DATA.append([_g(0,5.14,3,10),_g(5.71,11.785,2,15),_g(14.275,17.395,4,5)])
	# Round 13
	WAVE_DATA.append([_g(0,27.42,1,100),_g(11.42,12.774,4,4),_g(17.13,30.834,3,23)])
	# Round 14
	WAVE_DATA.append([_g(0,9.707,1,18),_g(2.855,3.975,2,5),_g(5.71,6.83,3,5),_g(8.565,9.515,4,4),
		_g(9.5,26.63,1,31),_g(15.9625,17.35,2,10),_g(19.8375,21.225,3,5),_g(23.708,25.262,4,5)])
	# Round 15
	WAVE_DATA.append([_g(0,10.85,1,20),_g(12.42,13.25,5,3),_g(15.13,23.13,3,12),_g(23.195,25.845,4,5)])
	# Round 16
	WAVE_DATA.append([_g(0,10.85,3,20),_g(1.675,16.2625,5,4),_g(13.58,15.01,4,8)])
	# Round 17
	WAVE_DATA.append([_g(0,3.997,4,8,false,true)])
	# Round 18
	WAVE_DATA.append([_g(0,25,3,60),_g(25,26.82,3,20)])
	# Round 19
	WAVE_DATA.append([_g(0,2.887,3,10),_g(2.33,5.185,4,5,false,true),_g(5.95,13.57,5,7),_g(13.5,15.784,4,4)])
	# Round 20
	WAVE_DATA.append([_g(0,5.245,6,6)])
	# Round 21
	WAVE_DATA.append([_g(0,5.14,5,10),_g(5.71,7.1475,5,4)])
	# Round 22
	WAVE_DATA.append([_g(0,4.568,7,8)])
	# Round 23
	WAVE_DATA.append([_g(0,1.9375,6,5),_g(5.758,7.612,7,4)])
	# Round 24
	WAVE_DATA.append([_g(0,0,3,1,true,false)])
	# Round 25
	WAVE_DATA.append([_g(0,17.13,4,31,false,true)])
	# Round 26
	WAVE_DATA.append([_g(0,8.7,5,23),_g(11,14.425,8,4)])
	# Round 27
	WAVE_DATA.append([_g(0,7.725,4,45),_g(9.42,16.765,3,45),_g(19,24.53,2,55),_g(24.58,31.0175,1,120)])
	# Round 28
	WAVE_DATA.append([_g(0,4,9,4)])
	# Round 29
	WAVE_DATA.append([_g(0,9,4,25),_g(13.5,15.612,5,12,false,true)])
	# Round 30
	WAVE_DATA.append([_g(0,13,9,9)])
	# Round 31
	WAVE_DATA.append([_g(0,5.085,8,8),_g(5.92,7.633,8,2,false,true)])
	# Round 32
	WAVE_DATA.append([_g(0,13.7,6,25),_g(14.275,30.775,7,28),_g(31.405,35.402,9,8)])
	# Round 33
	WAVE_DATA.append([_g(0,25.5,4,20,true,false)])
	# Round 34
	WAVE_DATA.append([_g(0,34.113,4,140),_g(7.5,25.6,8,5)])
	# Round 35
	WAVE_DATA.append([_g(0,10,7,25),_g(14.35,16.634,10,5),_g(19.2125,26.2075,5,35)])
	# Round 36
	WAVE_DATA.append([_g(3.5,5.0125,5,20),_g(11.92,13.265,5,20),_g(20.42,23.253,5,41)])
	# Round 37
	WAVE_DATA.append([_g(0,10.85,6,20),_g(11.42,22.27,7,20),_g(22.84,30.834,9,15),
		_g(31.405,36.545,8,10),_g(41.92,43.51,7,7,true,false)])
	# Round 38
	WAVE_DATA.append([_g(0,3.6,7,17),_g(2,25.411,5,42,false,true),_g(4.83,13.395,9,14),
		_g(12.0875,18.3675,8,10),_g(25.725,28.58,10,4)])
	# Round 39
	WAVE_DATA.append([_g(0,5.14,6,10),_g(5.71,10.85,7,10),_g(11.42,18.6825,9,20),
		_g(22.84,33.69,8,20),_g(34.26,43.967,10,18)])
	# Round 40
	WAVE_DATA.append([_g(0,5.14,10,10),_g(7.9625,9.6755,11,4)])
	# Round 41
	WAVE_DATA.append([_g(0,18.77,6,60),_g(18.85,46.208,8,60)])
	# Round 42
	WAVE_DATA.append([_g(0,5,10,6,false,true),_g(6,11,10,6,true,false)])
	# Round 43
	WAVE_DATA.append([_g(0,5.14,10,10),_g(5.71,9.26,11,7)])
	# Round 44
	WAVE_DATA.append([_g(0,10,8,10),_g(9.92,16.92,8,10),_g(20.75,22.75,8,10),_g(22.67,23.67,8,10)])
	# Round 45
	WAVE_DATA.append([_g(0,13.704,10,25),_g(14.275,75.005,5,200),_g(75,79,9,8)])
	# Round 46
	WAVE_DATA.append([_g(0,0,12,1)])
	# Round 47
	WAVE_DATA.append([_g(0,6.281,11,12),_g(6.5,24.645,5,70,true,false)])
	# Round 48
	WAVE_DATA.append([_g(0,39.7,5,120,false,true),_g(39.68,63.072,10,50)])
	# Round 49
	WAVE_DATA.append([_g(0,55.344,3,343),_g(4,9.14,10,10),_g(15.5,22.04,11,18),
		_g(29.275,32.788,8,20),_g(43,48.14,10,10),_g(43,48.14,10,10,false,true)])
	# Round 50
	WAVE_DATA.append([_g(0,0,12,1),_g(0.571,4.568,9,8),_g(9.8875,11.2325,1,20),
		_g(16.56,27.41,11,20),_g(28,28,12,1)])
	# Round 51
	WAVE_DATA.append([_g(0,15.42,11,20),_g(15.988,21.128,10,18,false,true)])
	# Round 52
	WAVE_DATA.append([_g(0,13.7,10,25),_g(14.275,14.275,12,1),_g(14.85,17.134,11,5),
		_g(17.7,17.7,12,1),_g(18.272,20.556,11,5)])
	# Round 53
	WAVE_DATA.append([_g(0,45.11,5,80,true,false),_g(27.9625,27.9625,12,1),
		_g(31.976,31.976,12,1),_g(35.733,35.733,12,1)])
	# Round 54
	WAVE_DATA.append([_g(0,19.414,11,35),_g(6.23,6.23,12,1),_g(11.991,11.991,12,1)])
	# Round 55
	WAVE_DATA.append([_g(1.17,2.8075,11,10),_g(7.83,9.3,11,10),_g(14.42,15.89,11,10),
		_g(22.17,23.08,11,10),_g(28.78,28.78,12,1)])
	# Round 56
	WAVE_DATA.append([_g(0,12,10,40,false,true),_g(15.18,15.18,12,1)])
	# Round 57
	WAVE_DATA.append([_g(0,0.571,12,2),_g(0.975,26.225,10,40),_g(12.56,13.131,12,2)])
	# Round 58
	WAVE_DATA.append([_g(0,43.98,12,5),_g(0,44.15,11,29)])
	# Round 59
	WAVE_DATA.append([_g(0,27.979,11,50),_g(10.2,17.65,9,28,true,false)])
	# Round 60
	WAVE_DATA.append([_g(0,0,13,1)])
	# Round 61
	WAVE_DATA.append([_g(0,20,8,150,false,true),_g(1.92,15.92,12,5)])
	# Round 62
	WAVE_DATA.append([_g(1.08,26.08,12,6),_g(1.142,57.662,5,300,true,false),_g(57.5,65.494,10,15,true,true)])
	# Round 63
	WAVE_DATA.append([_g(0,42.254,9,75),_g(3.88,4.08,11,40),_g(20.08,20.28,11,40),_g(36.42,36.62,11,42)])
	# Round 64
	WAVE_DATA.append([_g(0,5.75,12,9)])
	# Round 65
	WAVE_DATA.append([_g(0,32.35,8,100),_g(32.59,46.9,10,70),_g(47.32,58.17,11,50),
		_g(58.57,59.14,12,3),_g(60,62,13,2)])
	# Round 66
	WAVE_DATA.append([_g(0,0.5,12,2),_g(7,7.5,12,2),_g(13.92,14.92,12,4),_g(20.75,21.5,12,4)])
	# Round 67
	WAVE_DATA.append([_g(0,2.284,12,5),_g(9.1,17.094,11,15),_g(24.15,26.434,12,5)])
	# Round 68
	WAVE_DATA.append([_g(0,1.713,12,4),_g(7.442,7.442,13,1)])
	# Round 69
	WAVE_DATA.append([_g(0,16.55,9,60),_g(17.13,59.07,11,70,false,true)])
	# Round 70
	WAVE_DATA.append([_g(0,40,10,200,true,false),_g(40,41.142,12,4)])
	# Round 71
	WAVE_DATA.append([_g(0,16.55,11,30),_g(4.42,9.42,12,10)])
	# Round 72
	WAVE_DATA.append([_g(0,21.68,11,38,false,true),_g(3.42,3.42,13,1),_g(16.12,16.12,13,1)])
	# Round 73
	WAVE_DATA.append([_g(0,2.284,12,7),_g(13.4,16.4,13,2),_g(26.38,26.951,12,2)])
	# Round 74
	WAVE_DATA.append([_g(0,56.53,11,100),_g(41.43,41.43,13,1)])
	# Round 75
	WAVE_DATA.append([_g(0,0,13,1),_g(0.571,8.001,9,14),_g(8.565,9.136,12,2),_g(9.71,9.71,13,1),
		_g(10.278,17.708,9,14),_g(18.272,18.843,12,2),_g(22.4875,22.4875,13,1)])
	# Round 76
	WAVE_DATA.append([_g(0,1.77,11,60,false,true)])
	# Round 77
	WAVE_DATA.append([_g(0,58.92,12,14),_g(26.67,31.224,13,5)])
	# Round 78
	WAVE_DATA.append([_g(0,90,10,150),_g(10,11.17,11,75),_g(44.08,44.08,13,1),_g(77.92,79.12,11,72,true,false)])
	# Round 79
	WAVE_DATA.append([_g(0,60,10,500,false,true),_g(3.2,56.15,13,7)])
	# Round 80
	WAVE_DATA.append([_g(0,20,12,31)])
	# Round 81
	WAVE_DATA.append([_g(0,20,13,9)])
	# Round 82
	WAVE_DATA.append([_g(0,60,10,400,true,true),_g(0,20,13,10)])
	# Round 83
	WAVE_DATA.append([_g(0,60,11,50),_g(0.1,60.1,11,50),_g(0.2,60.2,11,50),_g(10,20,12,30)])
	# Round 84
	WAVE_DATA.append([_g(0,25,12,50),_g(5,25,13,10)])
	# Round 85
	WAVE_DATA.append([_g(0,0,14,1)])
