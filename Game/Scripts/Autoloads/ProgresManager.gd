extends Node

const SAVE_PATH = "user://progress.cfg"
const LEVEL_ORDER = ["tutorial", "level_1", "level_2", "level_3", "level_4", "level_5", "sandbox"]

var unlocked_levels: Array = ["tutorial"]
var unlocked_enemies: Array = ["1"]
var killed_enemy_counts: Dictionary = {}
var beaten_levels: Array = []
var unlocked_towers: Array = [1, 2, 3, 4, 5, 6, 7, 8]

func _ready() -> void :
    load_progress()

func save_progress() -> void :
    var cfg = ConfigFile.new()
    cfg.set_value("progress", "unlocked_levels", unlocked_levels)
    cfg.set_value("progress", "unlocked_enemies", unlocked_enemies)
    cfg.set_value("progress", "killed_enemy_counts", killed_enemy_counts)
    cfg.set_value("progress", "beaten_levels", beaten_levels)
    cfg.set_value("progress", "unlocked_towers", unlocked_towers)
    cfg.save(SAVE_PATH)

func load_progress() -> void :
    var cfg = ConfigFile.new()
    if cfg.load(SAVE_PATH) == OK:
        unlocked_levels = cfg.get_value("progress", "unlocked_levels", ["tutorial"])
        unlocked_enemies = cfg.get_value("progress", "unlocked_enemies", [])
        beaten_levels = cfg.get_value("progress", "beaten_levels", [])
        unlocked_towers = cfg.get_value("progress", "unlocked_towers", [1])
        if 1 not in unlocked_towers:
            unlocked_towers.append(1)
        var raw = cfg.get_value("progress", "killed_enemy_counts", {})
        if raw is Dictionary:
            killed_enemy_counts = raw
        else:
            killed_enemy_counts = {}

func mark_level_beaten(level_key: String) -> void :
    if level_key not in beaten_levels:
        beaten_levels.append(level_key)
        save_progress()

func is_level_beaten(level_key: String) -> bool:
    return level_key in beaten_levels

func is_level_unlocked(level_key: String) -> bool:
    return level_key in unlocked_levels

func unlock_next_level_after(level_key: String) -> void :
    var idx = LEVEL_ORDER.find(level_key)
    if idx >= 0 and idx + 1 < LEVEL_ORDER.size():
        var next = LEVEL_ORDER[idx + 1]
        if next not in unlocked_levels:
            unlocked_levels.append(next)
            save_progress()

func on_enemy_killed(enemy_id: int) -> void :
    if enemy_id not in unlocked_enemies:
        unlocked_enemies.append(enemy_id)
    killed_enemy_counts[enemy_id] = killed_enemy_counts.get(enemy_id, 0) + 1
    save_progress()

func unlock_all_enemies(max_id: int) -> void :
    for i in range(1, max_id + 1):
        if i not in unlocked_enemies:
            unlocked_enemies.append(i)
    save_progress()
