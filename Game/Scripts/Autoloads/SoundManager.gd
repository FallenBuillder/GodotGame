extends Node

# --- CONFIGURATION SECTION ---
# Vector2(Pitch, Volume_dB)  help taki trochę jakby ktoś dodawał dzwięki
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

var sounds: Dictionary = {}

func _ready() -> void:
	_load_sounds_from_folder("res://Game/Sounds/")
	
func _load_sounds_from_folder(path: String) -> void:
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



func play_constant(sound_name: String) -> void:
	var config = sound_configs.get(sound_name, Vector2(1.0, 0.0))
	_create_player(sound_name, config.y, config.x)

func play_random_pitch(sound_name: String) -> void:
	var config = sound_configs.get(sound_name, Vector2(1.0, 0.0))
	var random_pitch = randf_range(config.x - 0.1, config.x + 0.1)
	_create_player(sound_name, config.y, random_pitch)


func _create_player(sound_name: String, vol: float, pitch: float) -> void:
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
