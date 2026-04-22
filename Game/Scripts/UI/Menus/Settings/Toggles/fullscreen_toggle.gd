extends Button

var icon_fullscreen = preload("res://Game/Graphics/Temp/minimalize2.png")
var icon_windowed = preload("res://Game/Graphics/Temp/minimalize2.png")

const GAME_ASPECT_W: = 16
const GAME_ASPECT_H: = 9
const DEFAULT_WINDOWED_WIDTH: = 1280
const DEFAULT_WINDOWED_HEIGHT: = 720

func _ready() -> void :
    if not pressed.is_connected(_on_pressed):
        pressed.connect(_on_pressed)
    _update_icon()

func _on_pressed() -> void :
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        _enforce_aspect_ratio()
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    _update_icon()

func _enforce_aspect_ratio() -> void :
    var current_size = DisplayServer.window_get_size()
    var w: int = current_size.x
    var h: int = current_size.y

    var new_w: int = 0
    var new_h: int = 0

    new_h = int(float(w) * GAME_ASPECT_H / GAME_ASPECT_W)
    if new_h > h:
        new_h = h
        new_w = int(float(h) * GAME_ASPECT_W / GAME_ASPECT_H)
    else:
        new_w = w

    if new_w < 640:
        new_w = DEFAULT_WINDOWED_WIDTH
        new_h = DEFAULT_WINDOWED_HEIGHT

    DisplayServer.window_set_size(Vector2i(new_w, new_h))

    get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND

func _update_icon() -> void :
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        icon = icon_windowed
    else:
        icon = icon_fullscreen
