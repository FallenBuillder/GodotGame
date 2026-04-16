extends Control

@onready var game_viewport = $GameViewport
@onready var bottom_info = $"Bottom Info"
@onready var shop_info_panel = $ShopInfoPanel
@onready var shop_money_label = $ShopInfoPanel/VBoxContainer/MoneyContainer/ShopMoneyLabel
@onready var shop_health_label = $ShopInfoPanel/VBoxContainer/HealthContainer/ShopHealthLabel
@onready var wave_select_container = $ShopInfoPanel/VBoxContainer/WaveSelectContainer
@onready var wave_input = $ShopInfoPanel/VBoxContainer/WaveSelectContainer/WaveInput
@onready var start_wave_btn = $ShopInfoPanel/VBoxContainer/WaveSelectContainer/StartWaveButton
@onready var game_ui = $"Game UI"
@onready var tower_shop = $"Tower Shop"
@onready var enemy_shop = $"Enemy Shop"
@onready var tower_info = $"Tower Info"

var current_level_scene: Node = null
var level_path := ""

func _ready() -> void:
	GameManager.layout_node = self
	GameManager._on_reset_callback = Callable()
	GameManager._sandbox_mode = false

	GameManager.money_changed.connect(_on_money_changed)
	GameManager.health_changed.connect(_on_health_changed)

	shop_money_label.text = "$%d" % GameManager.money
	shop_health_label.text = "%d" % GameManager.health

	wave_select_container.visible = false

	if level_path != "":
		await load_level(level_path)
		call_deferred("_refresh_wave_label")

	var saved = GameManager.get_saved_wave_for_level(level_path)
	if saved > 1 and GameManager.ui and GameManager.ui.has_method("set_start_wave"):
		GameManager.ui.set_start_wave(saved)
		
	var settings_button = get_node_or_null("Panel/UIButtonsContainer/SettingsButton")
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	

func _input(event: InputEvent) -> void:
	if not GameManager.level_node:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if PlacementManager.preview_tower != null:
			return
		var vp_container = get_node_or_null("GameViewport")
		if vp_container and not vp_container.get_global_rect().has_point(get_viewport().get_mouse_position()):
			return
		var sub_vp = get_node_or_null("GameViewport/SubViewport")
		if not sub_vp:
			return
		var mouse_pos = GameManager.level_node.get_local_mouse_position()
		var clicked_tower: Node = null
		for tower in get_tree().get_nodes_in_group("towers"):
			if not tower.is_placed:
				continue
			var shape_node = tower.get_node_or_null("ClickArea/CollisionShape2D")
			if shape_node and shape_node.shape is CircleShape2D:
				if tower.global_position.distance_to(mouse_pos) <= shape_node.shape.radius * tower.scale.x:
					clicked_tower = tower
					break
		if clicked_tower:
			clicked_tower.on_clicked()
			get_viewport().set_input_as_handled()
		else:
			_deselect_all_towers()

func _deselect_all_towers() -> void:
	for tower in get_tree().get_nodes_in_group("towers"):
		tower.set_selected(false)
	if tower_info:
		tower_info.hide_info()

func _refresh_wave_label() -> void:
	var bi = get_node_or_null("Bottom Info")
	if bi and bi.has_method("_update_label"):
		bi._update_label()

func load_level(path: String) -> void:
	if current_level_scene:
		current_level_scene.queue_free()
		await get_tree().process_frame

	var scene = load(path)
	if not scene:
		push_error("Failed to load level: ", path)
		return

	current_level_scene = scene.instantiate()
	var sub_vp = get_node("GameViewport/SubViewport")
	sub_vp.add_child(current_level_scene)
	sub_vp.handle_input_locally = false
	sub_vp.physics_object_picking = true
	sub_vp.physics_object_picking_sort = true

	var cam = current_level_scene.get_node_or_null("Camera2D")
	if cam:
		cam.make_current()

func show_tower_info(tower: Node) -> void:
	if not tower_info:
		push_error("Tower Info node is null in layout!")
		return
	if bottom_info:
		bottom_info.hide()
	tower_info.show_tower_info(tower)

func hide_tower_info() -> void:
	if tower_info:
		tower_info.hide_info()

func show_tower_shop() -> void:
	if tower_shop:
		tower_shop.show()
	if enemy_shop:
		enemy_shop.hide()

func show_enemy_shop() -> void:
	if enemy_shop:
		enemy_shop.show()
	if tower_shop:
		tower_shop.hide()

func toggle_shop() -> void:
	if tower_shop and tower_shop.visible:
		show_enemy_shop()
	else:
		show_tower_shop()

func show_sandbox_wave_select() -> void:
	wave_select_container.visible = true
	wave_input.max_length = 2
	if not start_wave_btn.pressed.is_connected(_on_sandbox_wave_select):
		start_wave_btn.pressed.connect(_on_sandbox_wave_select)
	if not wave_input.text_changed.is_connected(_on_sandbox_wave_input_changed):
		wave_input.text_changed.connect(_on_sandbox_wave_input_changed)

func _on_sandbox_wave_input_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		GameManager.change_wave(clamp(int(new_text), 1, 85))

func _on_sandbox_wave_select() -> void:
	if not wave_input.text.is_valid_int():
		return
	WaveManager.start_wave(clamp(int(wave_input.text), 1, 85))

func _on_money_changed(value: int) -> void:
	shop_money_label.text = "$%d" % value

func _on_health_changed(value: int) -> void:
	shop_health_label.text = "%d" % value


var game_menu_scene = preload("res://Game/Scenes/UI/Game UI/Game Menu/game_menu.tscn")
func _on_settings_button_pressed() -> void:
	var menu = game_menu_scene.instantiate()
	add_child(menu)
	get_tree().paused = true
