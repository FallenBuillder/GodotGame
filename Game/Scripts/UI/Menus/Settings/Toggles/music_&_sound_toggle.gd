extends Button

@export var bus_name: String = "Master"

var icon_music = preload("res://Game/Graphics/Temp/sound2.png")
var icon_sounds = preload("res://Game/Graphics/Temp/sound2.png")
var icon_muted = preload("res://Game/Graphics/Temp/mute2.png")

var icon_on: Texture2D
var muted: = false

func _ready():
    if pressed.is_connected(_on_pressed):
        pressed.disconnect(_on_pressed)

    flat = true
    icon_on = icon_music if bus_name == "Music" else icon_sounds
    icon = icon_on
    pressed.connect(_on_pressed)

func _on_pressed():
    muted = !muted
    var bus_index = AudioServer.get_bus_index(bus_name)
    AudioServer.set_bus_mute(bus_index, muted)
    icon = icon_muted if muted else icon_on
