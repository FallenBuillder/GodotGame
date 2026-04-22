extends Node

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed
signal level_max_wave_changed(max_wave: int)

var _level_max_wave: int = 85
var is_auto_start: = false
var current_path: Path2D
var is_running: = false
var _enemies_alive: = 0
var _wave_spawning: = false
var _total_waves: = 85
var _current_wave_duration: = 0.0

var WAVE_DATA: Array = [
    load("res://Game/Data/Waves/wave_001.tres"), 
    load("res://Game/Data/Waves/wave_002.tres"), 
    load("res://Game/Data/Waves/wave_003.tres"), 
    load("res://Game/Data/Waves/wave_004.tres"), 
    load("res://Game/Data/Waves/wave_005.tres"), 
    load("res://Game/Data/Waves/wave_006.tres"), 
    load("res://Game/Data/Waves/wave_007.tres"), 
    load("res://Game/Data/Waves/wave_008.tres"), 
    load("res://Game/Data/Waves/wave_009.tres"), 
    load("res://Game/Data/Waves/wave_010.tres"), 
    load("res://Game/Data/Waves/wave_011.tres"), 
    load("res://Game/Data/Waves/wave_012.tres"), 
    load("res://Game/Data/Waves/wave_013.tres"), 
    load("res://Game/Data/Waves/wave_014.tres"), 
    load("res://Game/Data/Waves/wave_015.tres"), 
    load("res://Game/Data/Waves/wave_016.tres"), 
    load("res://Game/Data/Waves/wave_017.tres"), 
    load("res://Game/Data/Waves/wave_018.tres"), 
    load("res://Game/Data/Waves/wave_019.tres"), 
    load("res://Game/Data/Waves/wave_020.tres"), 
    load("res://Game/Data/Waves/wave_021.tres"), 
    load("res://Game/Data/Waves/wave_022.tres"), 
    load("res://Game/Data/Waves/wave_023.tres"), 
    load("res://Game/Data/Waves/wave_024.tres"), 
    load("res://Game/Data/Waves/wave_025.tres"), 
    load("res://Game/Data/Waves/wave_026.tres"), 
    load("res://Game/Data/Waves/wave_027.tres"), 
    load("res://Game/Data/Waves/wave_028.tres"), 
    load("res://Game/Data/Waves/wave_029.tres"), 
    load("res://Game/Data/Waves/wave_030.tres"), 
    load("res://Game/Data/Waves/wave_031.tres"), 
    load("res://Game/Data/Waves/wave_032.tres"), 
    load("res://Game/Data/Waves/wave_033.tres"), 
    load("res://Game/Data/Waves/wave_034.tres"), 
    load("res://Game/Data/Waves/wave_035.tres"), 
    load("res://Game/Data/Waves/wave_036.tres"), 
    load("res://Game/Data/Waves/wave_037.tres"), 
    load("res://Game/Data/Waves/wave_038.tres"), 
    load("res://Game/Data/Waves/wave_039.tres"), 
    load("res://Game/Data/Waves/wave_040.tres"), 
    load("res://Game/Data/Waves/wave_041.tres"), 
    load("res://Game/Data/Waves/wave_042.tres"), 
    load("res://Game/Data/Waves/wave_043.tres"), 
    load("res://Game/Data/Waves/wave_044.tres"), 
    load("res://Game/Data/Waves/wave_045.tres"), 
    load("res://Game/Data/Waves/wave_046.tres"), 
    load("res://Game/Data/Waves/wave_047.tres"), 
    load("res://Game/Data/Waves/wave_048.tres"), 
    load("res://Game/Data/Waves/wave_049.tres"), 
    load("res://Game/Data/Waves/wave_050.tres"), 
    load("res://Game/Data/Waves/wave_051.tres"), 
    load("res://Game/Data/Waves/wave_052.tres"), 
    load("res://Game/Data/Waves/wave_053.tres"), 
    load("res://Game/Data/Waves/wave_054.tres"), 
    load("res://Game/Data/Waves/wave_055.tres"), 
    load("res://Game/Data/Waves/wave_056.tres"), 
    load("res://Game/Data/Waves/wave_057.tres"), 
    load("res://Game/Data/Waves/wave_058.tres"), 
    load("res://Game/Data/Waves/wave_059.tres"), 
    load("res://Game/Data/Waves/wave_060.tres"), 
    load("res://Game/Data/Waves/wave_061.tres"), 
    load("res://Game/Data/Waves/wave_062.tres"), 
    load("res://Game/Data/Waves/wave_063.tres"), 
    load("res://Game/Data/Waves/wave_064.tres"), 
    load("res://Game/Data/Waves/wave_065.tres"), 
    load("res://Game/Data/Waves/wave_066.tres"), 
    load("res://Game/Data/Waves/wave_067.tres"), 
    load("res://Game/Data/Waves/wave_068.tres"), 
    load("res://Game/Data/Waves/wave_069.tres"), 
    load("res://Game/Data/Waves/wave_070.tres"), 
    load("res://Game/Data/Waves/wave_071.tres"), 
    load("res://Game/Data/Waves/wave_072.tres"), 
    load("res://Game/Data/Waves/wave_073.tres"), 
    load("res://Game/Data/Waves/wave_074.tres"), 
    load("res://Game/Data/Waves/wave_075.tres"), 
    load("res://Game/Data/Waves/wave_076.tres"), 
    load("res://Game/Data/Waves/wave_077.tres"), 
    load("res://Game/Data/Waves/wave_078.tres"), 
    load("res://Game/Data/Waves/wave_079.tres"), 
    load("res://Game/Data/Waves/wave_080.tres"), 
    load("res://Game/Data/Waves/wave_081.tres"), 
    load("res://Game/Data/Waves/wave_082.tres"), 
    load("res://Game/Data/Waves/wave_083.tres"), 
    load("res://Game/Data/Waves/wave_084.tres"), 
    load("res://Game/Data/Waves/wave_085.tres")
]

var _scene_cache: Dictionary = {
    1: "res://Game/Scenes/Enemies/1_basic_enemy.tscn", 
    2: "res://Game/Scenes/Enemies/2_basic_enemy.tscn", 
    3: "res://Game/Scenes/Enemies/3_basic_enemy.tscn", 
    4: "res://Game/Scenes/Enemies/4_basic_enemy.tscn", 
    5: "res://Game/Scenes/Enemies/5_basic_enemy.tscn", 
    6: "res://Game/Scenes/Enemies/6_explosion_enemy.tscn", 
    7: "res://Game/Scenes/Enemies/7_freeze_enemy.tscn", 
    8: "res://Game/Scenes/Enemies/8_freeze_&_explosion_enemy.tscn", 
    9: "res://Game/Scenes/Enemies/9_sharp_enemy.tscn", 
    10: "res://Game/Scenes/Enemies/10_basic_enemy.tscn", 
    11: "res://Game/Scenes/Enemies/11_resilient_enemy.tscn", 
    12: "res://Game/Scenes/Enemies/12_boss_enemy.tscn", 
    13: "res://Game/Scenes/Enemies/13_boss_enemy.tscn", 
    14: "res://Game/Scenes/Enemies/14_boss_enemy.tscn"
}


const LEVEL_MAX_WAVES: Dictionary = {
    "tutorial": 25, 
    "level_1": 50, 
    "level_2": 55, 
    "level_3": 65, 
    "level_4": 75, 
    "level_5": 85, 
}





func set_level_max_wave(level_key: String) -> void :
    _level_max_wave = LEVEL_MAX_WAVES.get(level_key, 85)
    level_max_wave_changed.emit(_level_max_wave)

func get_level_max_wave() -> int:
    return _level_max_wave

func setup_path(path_node: Path2D) -> void :
    current_path = path_node

func get_total_waves() -> int:
    return _total_waves

func start_wave(wave_number: int) -> void :
    if not current_path or not is_instance_valid(current_path):
        push_warning("WaveManger: no valid path set")
        return
    if is_running:
        return
    if wave_number < 1 or wave_number > _total_waves:
        return

    is_running = true
    _wave_spawning = true
    _enemies_alive = 0

    GameManager.change_wave(wave_number)
    wave_started.emit(wave_number)

    var wave_res: WaveData = WAVE_DATA[wave_number - 1]
    var groups: Array = wave_res.groups
    _current_wave_duration = 0.0
    for g in groups:
        if g.end > _current_wave_duration:
            _current_wave_duration = g.end
    _current_wave_duration += 10.0
    await _run_wave_groups(groups)

    _wave_spawning = false
    _check_wave_done(wave_number)

func reset() -> void :
    is_running = false
    _wave_spawning = false
    _enemies_alive = 0
    _level_max_wave = 85
    if current_path:
        for child in current_path.get_children():
            if child.name != "PathBlocker":
                child.queue_free()

func on_enemy_removed() -> void :
    _enemies_alive -= 1
    if _enemies_alive < 0:
        _enemies_alive = 0
    if not _wave_spawning:
        _check_wave_done(GameManager.wave)

func _check_wave_done(wave_number: int) -> void :
    if _enemies_alive <= 0 and not _wave_spawning and is_running:
        is_running = false
        if not GameManager._sandbox_mode:
            var reward = 100 + (wave_number - 1)
            GameManager.add_money(reward)
        wave_completed.emit(wave_number)
        if wave_number >= _total_waves:
            all_waves_completed.emit()
        elif is_auto_start:
            var next = wave_number + 1
            if next <= _level_max_wave:
                await get_tree().create_timer(1.0).timeout
                start_wave(next)

func _run_wave_groups(groups: Array) -> void :
    var max_time: = 0.0
    for g in groups:
        var end_t: float = g.end if g.end > g.start else g.start + 0.1
        if end_t > max_time:
            max_time = end_t

    for g in groups:
        _spawn_group_delayed(g)

    await get_tree().create_timer(max_time).timeout

func _spawn_enemy(enemy_id: int, camo: bool, regen: bool) -> void :
    if not current_path:
        return
    if not is_instance_valid(current_path):
        return
    var scene_path = get_enemy_scene_path(enemy_id)
    if scene_path == "":
        push_warning("WaveManager: no scene for enemy_id " + str(enemy_id))
        return
    var enemy_scene = load(scene_path)
    var path_follow = PathFollow2D.new()
    var enemy = enemy_scene.instantiate()

    if camo:
        enemy.set_camo(true)
    if regen:
        enemy.set_regen(true)

    var _counted: = [false]
    enemy.tree_exited.connect( func():
        if not _counted[0]:
            _counted[0] = true
            on_enemy_removed()
    )

    _enemies_alive += 1
    enemy.setup(path_follow)
    path_follow.add_child(enemy)
    current_path.add_child(path_follow)

func _spawn_group_delayed(group: WaveGroupData) -> void :
    if group.start > 0.0:
        await get_tree().create_timer(group.start).timeout
    var duration: float = max(group.end - group.start, 0.0)
    var interval: float = duration / float(max(group.count, 1))
    for i in range(group.count):
        if not is_running:
            return
        _spawn_enemy(group.enemy_id, group.camo, group.regen)
        if i < group.count - 1 and interval > 0.0:
            await get_tree().create_timer(interval).timeout

func _build_scene_cache() -> void :
    _scene_cache.clear()
    var dir = "res://Game/Scenes/Enemies/"
    var da = DirAccess.open(dir)
    if not da:
        return
    for f in da.get_files():
        if not f.ends_with(".tscn"):
            continue
        var base = f.get_basename()
        if "_camo" in base or "_regen" in base:
            continue
        var parts = base.split("_")
        if parts.size() == 0 or not parts[0].is_valid_int():
            continue
        var id = int(parts[0])
        _scene_cache[id] = dir + f

func get_enemy_scene_path(id: int, _is_camo: bool = false, _is_regen: bool = false) -> String:
    return _scene_cache.get(id, "")

func _g(start: float, end: float, eid: int, count: int, 
        camo: bool = false, regen: bool = false) -> Dictionary:
    return {"start": start, "end": end, "enemy_id": eid, 
            "count": count, "camo": camo, "regen": regen}

func _load_wave_data() -> void :
    WAVE_DATA.clear()
    var dir = "res://Game/Data/Waves/"
    var da = DirAccess.open(dir)
    if not da:
        push_error("WaveManager: no Waves folder at " + dir)
        return
    var files = da.get_files()
    files.sort()
    for f in files:
        if not f.ends_with(".tres"):
            continue
        var res = load(dir + f)
        if res is WaveData:
            WAVE_DATA.append(res)
    _total_waves = WAVE_DATA.size()

func get_wave_duration() -> float:
    return _current_wave_duration
