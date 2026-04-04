extends Panel

@export var tower_scene: PackedScene
@export var tower_name: String = "Tower"
@export var tower_cost: int = 100
@export var tower_icon: Texture2D

@onready var cost_label = $VBoxContainer/CostLabel
@onready var name_label = $VBoxContainer/NameLabel
@onready var icon_rect = $VBoxContainer/TextureRect

var can_afford := true
var preview_tower = null
var shop_width: float = 200.0

var is_dragging := false
var drag_start_x := 0.0
var drag_distance := 0.0
const DRAG_THRESHOLD := 5

func _ready():
	name_label.text = tower_name
	cost_label.text = "$" + str(tower_cost)
	icon_rect.texture = tower_icon
	
	get_shop_width()
	
	GameManager.money_changed.connect(_on_money_changed)
	update_affordability()

func get_shop_width():
	var current = self
	while current:
		if current is CanvasLayer:
			var panel = current.get_node_or_null("Panel")
			if panel:
				shop_width = panel.size.x
				return
		current = current.get_parent()

func _on_money_changed(_amount):
	update_affordability()

func update_affordability():
	can_afford = GameManager.money >= tower_cost
	modulate = Color.WHITE if can_afford else Color(0.5, 0.5, 0.5, 0.7)

# ==== CLICK AND DROP MODE ====
func _gui_input(event):
	if SettingsManager.placement_mode == SettingsManager.PlacementMode.CLICK_AND_DROP:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_afford and not preview_tower:
				start_preview()
	else:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and can_afford and not preview_tower:
				is_dragging = true
				drag_distance = 0
				drag_start_x = event.position.x

func _input(event):
	if SettingsManager.placement_mode == SettingsManager.PlacementMode.CLICK_AND_DROP:
		if preview_tower and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			attempt_placement()
			get_viewport().set_input_as_handled()
	
	elif SettingsManager.placement_mode == SettingsManager.PlacementMode.DRAG_AND_DROP:
		if event is InputEventMouseMotion and is_dragging:
			drag_distance += abs(event.relative.x)
			if drag_distance > DRAG_THRESHOLD and not preview_tower:
				start_preview()
		
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_dragging:
				is_dragging = false
				drag_distance = 0
				if preview_tower:
					attempt_placement()
	
	if preview_tower:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			cancel_preview()
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_preview()
			get_viewport().set_input_as_handled()

func start_preview():
	if not tower_scene:
		return
	
	preview_tower = tower_scene.instantiate()
	preview_tower.modulate = Color(1, 1, 1, 0.5)
	
	if preview_tower.has_method("set_preview_mode"):
		preview_tower.set_preview_mode(true)
	
	var level = get_tree().current_scene
	level.add_child(preview_tower)

func _process(_delta):
	if preview_tower:
		var viewport = get_viewport()
		var mouse_pos = viewport.get_mouse_position()
		
		var camera = get_viewport().get_camera_2d()
		if camera:
			mouse_pos = camera.get_global_mouse_position()
		
		preview_tower.global_position = mouse_pos
		
		var screen_mouse_pos = get_viewport().get_mouse_position()
		var screen_width = get_viewport().get_visible_rect().size.x
		
		if screen_mouse_pos.x > screen_width - shop_width:
			preview_tower.modulate = Color(1, 1, 0, 0.5)
		elif is_valid_placement():
			preview_tower.modulate = Color(0, 1, 0, 0.5)
		else:
			preview_tower.modulate = Color(1, 0, 0, 0.5)

func attempt_placement():
	if not preview_tower:
		return
	
	var screen_mouse_pos = get_viewport().get_mouse_position()
	var screen_width = get_viewport().get_visible_rect().size.x
	
	if screen_mouse_pos.x > screen_width - shop_width:
		cancel_preview()
		return
	
	var is_valid = is_valid_placement()
	
	if SettingsManager.placement_mode == SettingsManager.PlacementMode.CLICK_AND_DROP:
		if is_valid and GameManager.spend_money(tower_cost):
			finalize_tower()
	else:
		if is_valid and GameManager.spend_money(tower_cost):
			finalize_tower()
		else:
			cancel_preview()

func finalize_tower():
	preview_tower.modulate = Color.WHITE
	
	if preview_tower.has_method("set_preview_mode"):
		preview_tower.set_preview_mode(false)
	if preview_tower.has_method("finalize_placement"):
		preview_tower.finalize_placement()
	
	preview_tower = null
	is_dragging = false

func cancel_preview():
	if preview_tower:
		preview_tower.queue_free()
		preview_tower = null
	is_dragging = false

func is_valid_placement() -> bool:
	if not preview_tower:
		return false
	
	var placement_area = preview_tower.get_node_or_null("PlacementArea")
	if not placement_area:
		return true
	
	var overlapping = placement_area.get_overlapping_areas()
	return overlapping.is_empty()
