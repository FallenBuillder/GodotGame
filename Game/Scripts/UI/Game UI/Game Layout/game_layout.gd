extends Control

const GAME_WIDTH = 1280
const GAME_HEIGHT = 720
const SHOP_WIDTH = 300
const INFO_HEIGHT = 150

@onready var left_bar = $LeftBlackBar
@onready var right_bar = $RightBlackBar
@onready var game_viewport = $GameViewport
@onready var tower_shop = $TowerShop
@onready var bottom_info = $BottomInfo
@onready var tower_info_panel = $TowerInfoPanel

var current_level_scene: Node = null

func _ready() -> void:
	_setup_layout()
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _setup_layout() -> void:
	var window_size = get_viewport_rect().size
	
	var game_x = (window_size.x - GAME_WIDTH) / 2.0
	var game_y = (window_size.y - GAME_HEIGHT - INFO_HEIGHT) / 2.0
	
	left_bar.position = Vector2.ZERO
	left_bar.size = Vector2(game_x, window_size.y)
	
	var right_bar_x = game_x + GAME_WIDTH + SHOP_WIDTH
	right_bar.position = Vector2(right_bar_x, 0)
	right_bar.size = Vector2(window_size.x - right_bar_x, window_size.y)
	
	game_viewport.position = Vector2(game_x, game_y)
	game_viewport.size = Vector2(GAME_WIDTH, GAME_HEIGHT)
	
	tower_shop.position = Vector2(game_x + GAME_WIDTH, game_y)
	tower_shop.size = Vector2(SHOP_WIDTH, GAME_HEIGHT)
	
	bottom_info.position = Vector2(game_x, game_y + GAME_HEIGHT)
	bottom_info.size = Vector2(GAME_WIDTH + SHOP_WIDTH, INFO_HEIGHT)
	
	tower_info_panel.position = bottom_info.position
	tower_info_panel.size = bottom_info.size
	tower_info_panel.hide()

func _on_viewport_size_changed() -> void:
	_setup_layout()

func load_level(level_path: String) -> void:
	if current_level_scene:
		current_level_scene.queue_free()
	
	var level_scene = load(level_path)
	current_level_scene = level_scene.instantiate()
	$GameViewport/SubViewport.add_child(current_level_scene)

func show_tower_info(tower: Node) -> void:
	bottom_info.hide()
	tower_info_panel.show()
	tower_info_panel.display_tower(tower)

func hide_tower_info() -> void:
	tower_info_panel.hide()
	bottom_info.show()
	
