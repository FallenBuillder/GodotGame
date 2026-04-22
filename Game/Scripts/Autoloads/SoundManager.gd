extends Node



var sound_configs: Dictionary = {
    "tower_place": Vector2(1.0, -10.0), 
    "critical": Vector2(1.0, -10.0), 
    "Farm(tower)": Vector2(1.0, -10.0), 
    "engineer_place_turret": Vector2(1.0, -10.0), 
    "take_damage_base": Vector2(1.0, -20.0), 
    "CheeseDie1": Vector2(1.0, -17.5), 
    "CheeseDie2": Vector2(1.0, -17.5), 
    "freeze(tower)": Vector2(1.0, -15.0), 
    "box_punch(tower)": Vector2(1.0, -15.0), 
    "HomeMusic": Vector2(1.0, -14.0), 
    "intro": Vector2(1.0, 0.0)
}


var sounds: Dictionary = {
    "bomb_explode(tower)": preload("res://Game/Sounds/bomb_explode(tower).ogg"), 
    "box_punch(tower)": preload("res://Game/Sounds/box_punch(tower).ogg"), 
    "button(click)": preload("res://Game/Sounds/button(click).ogg"), 
    "button(hover)": preload("res://Game/Sounds/button(hover).ogg"), 
    "ceramic_hit_cancel": preload("res://Game/Sounds/ceramic_hit_cancel.ogg"), 
    "CheeseDie1": preload("res://Game/Sounds/CheeseDie1.ogg"), 
    "CheeseDie2": preload("res://Game/Sounds/CheeseDie2.ogg"), 
    "critical": preload("res://Game/Sounds/critical.ogg"), 
    "crossbow_shoot(tower)": preload("res://Game/Sounds/crossbow_shoot(tower).ogg"), 
    "engineer_place_turret": preload("res://Game/Sounds/engineer_place_turret.ogg"), 
    "Farm(tower)": preload("res://Game/Sounds/Farm(tower).ogg"), 
    "freeze(tower)": preload("res://Game/Sounds/freeze(tower).ogg"), 
    "game over ": preload("res://Game/Sounds/game over .mp3"), 
    "HomeMusic": preload("res://Game/Sounds/HomeMusic.ogg"), 
    "intro": preload("res://Game/Sounds/intro.mp3"), 
    "lead_hit_cancel": preload("res://Game/Sounds/lead_hit_cancel.ogg"), 
    "menu close": preload("res://Game/Sounds/menu close.ogg"), 
    "take_damage_base": preload("res://Game/Sounds/take_damage_base.ogg"), 
    "tower_place": preload("res://Game/Sounds/tower_place.ogg"), 
    "UpgradeTower": preload("res://Game/Sounds/UpgradeTower.ogg"), 
    "Victory_better": preload("res://Game/Sounds/Victory_better.ogg"), 
    "Victrory": preload("res://Game/Sounds/Victrory.ogg")
}




func _ready() -> void :
    _load_sounds_from_folder("res://Game/Sounds/")

func _load_sounds_from_folder(path: String) -> void :
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if !dir.current_is_dir():
                if file_name.ends_with(".ogg") or file_name.ends_with(".mp3") or file_name.ends_with(".wav"):
                    var sound_name = file_name.get_basename()
                    sounds[sound_name] = load(path + file_name)
            file_name = dir.get_next()
        dir.list_dir_end()



func play_constant(sound_name: String) -> void :
    var config = sound_configs.get(sound_name, Vector2(1.0, 0.0))
    _create_player(sound_name, config.y, config.x)

func play_random_pitch(sound_name: String) -> void :
    var config = sound_configs.get(sound_name, Vector2(1.0, 0.0))
    var random_pitch = randf_range(config.x - 0.1, config.x + 0.1)
    _create_player(sound_name, config.y, random_pitch)


func _create_player(sound_name: String, vol: float, pitch: float) -> void :
    if sounds.has(sound_name):
        var player = AudioStreamPlayer.new()
        add_child(player)
        player.stream = sounds[sound_name]
        player.volume_db = vol
        player.pitch_scale = pitch
        player.play()
        player.finished.connect(player.queue_free)
    else:
        push_error("AudioManager: Sound not found: " + sound_name)

func _play_home_song():
    play_constant("HomeMusic")
