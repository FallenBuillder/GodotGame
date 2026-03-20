extends Panel

@export var tower_scene: PackedScene
@export var tower_name: String = "Tower"
@export var tower_cost: int = 100
@export var tower_icon: Texture2D

@onready var cost_label = $VBoxContainer/CostLabel
@onready var name_label = $VBoxContainer/NameLabel
@onready var icon_rect = $VBoxContainer/TextureRect

var can_afford := true
var is_dragging := false
var preview_tower = null
var shop_width: float = 200.0

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

func _input(event):
	if is_dragging:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			cancel_drag()
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_drag()
			get_viewport().set_input_as_handled()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and can_afford:
			start_drag()
		elif not event.pressed and is_dragging:
			end_drag()

func start_drag():
	if not tower_scene:
		return
	
	is_dragging = true
	preview_tower = tower_scene.instantiate()
	preview_tower.modulate = Color(1, 1, 1, 0.5)
	
	# Enable range preview
	if preview_tower.has_method("set_preview_mode"):
		preview_tower.set_preview_mode(true)
	
	var level = get_tree().current_scene
	level.add_child(preview_tower)

func _process(_delta):
	if is_dragging and preview_tower:
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

func end_drag():
	if is_dragging and preview_tower:
		var screen_mouse_pos = get_viewport().get_mouse_position()
		var screen_width = get_viewport().get_visible_rect().size.x
		
		if screen_mouse_pos.x > screen_width - shop_width:
			cancel_drag()
			return
		
		if is_valid_placement() and GameManager.spend_money(tower_cost):
			preview_tower.modulate = Color.WHITE
			# Disable range preview after placing
			if preview_tower.has_method("set_preview_mode"):
				preview_tower.set_preview_mode(false)
		else:
			preview_tower.queue_free()
		
		is_dragging = false
		preview_tower = null

func cancel_drag():
	if is_dragging and preview_tower:
		preview_tower.queue_free()
		is_dragging = false
		preview_tower = null

func is_valid_placement() -> bool:
	if not preview_tower:
		return false
	
	var placement_area = preview_tower.get_node_or_null("PlacementArea")
	if not placement_area:
		return true
	
	var overlapping = placement_area.get_overlapping_areas()
	return overlapping.is_empty()
