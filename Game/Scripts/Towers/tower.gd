extends Node2D

enum FocusMode { FIRST, LAST, CLOSE, STRONG }

@export var detection_range := 300.0:
	set(value):
		detection_range = value
		update_detection_range()

@export var tower_name := "Tower"
@export var tower_id := 0
@export var unlocked := true
@export var fire_rate := 1.0
@export var damage := 25
@export var damage_type := 0
@export var pierce := 1
@export var projectile_speed := 500
@export var cost := 100
@export var bullet_scene: PackedScene

var focus_mode: FocusMode = FocusMode.FIRST
var closest_enemy = null
var enemies_in_range: Array = []
var total_damage_dealt := 0

var check_timer := 0.0
var fire_timer := 0.0

var show_range := false
var is_selected := false
var is_hovered := false
var is_placed := false
var is_preview := false

const CHECK_INTERVAL = 0.2
const HOVER_SCALE := Vector2(1.1, 1.1)
const SELECTED_SCALE := Vector2(1.1, 1.1)
const NORMAL_SCALE := Vector2(1.0, 1.0)

func _ready() -> void:
	add_to_group("towers")

	$Area2D.area_entered.connect(_on_enemy_entered)
	$Area2D.area_exited.connect(_on_enemy_exited)

	if has_node("ClickArea"):
		$ClickArea.input_event.connect(_on_click_area_input)
		$ClickArea.mouse_entered.connect(_on_mouse_entered)
		$ClickArea.mouse_exited.connect(_on_mouse_exited)
	
	update_detection_range()

func _physics_process(delta: float) -> void:
	if not is_placed:
		return
	
	turn(delta)
	shoot(delta)
	update_scale(delta)

func turn(delta: float) -> void:
	check_timer += delta
	
	if check_timer >= CHECK_INTERVAL:
		check_timer = 0.0
		update_closest_enemy()
	
	if closest_enemy and is_instance_valid(closest_enemy):
		look_at(closest_enemy.global_position)

func update_closest_enemy() -> void:
	if enemies_in_range.is_empty():
		closest_enemy = null
		return
	
	match focus_mode:
		FocusMode.FIRST:
			_target_first()
		FocusMode.LAST:
			_target_last()
		FocusMode.STRONG:
			_target_strong()
		FocusMode.CLOSE:
			_target_close()

func _target_first() -> void:
	var furthest_enemy = null
	var max_progress := -1.0
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		if not enemy.path_follow:
			continue
			
		if enemy.path_follow.progress_ratio > max_progress:
			max_progress = enemy.path_follow.progress_ratio
			furthest_enemy = enemy
	
	closest_enemy = furthest_enemy

func _target_last() -> void:
	var last_enemy = null
	var min_progress := 2.0
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		if not enemy.path_follow:
			continue
			
		if enemy.path_follow.progress_ratio < min_progress:
			min_progress = enemy.path_follow.progress_ratio
			last_enemy = enemy
	
	closest_enemy = last_enemy

func _target_strong() -> void:
	var strongest_enemy = null
	var max_type := -1
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
			
		if enemy.enemy_id > max_type:
			max_type = enemy.enemy_id
			strongest_enemy = enemy
	
	closest_enemy = strongest_enemy

func _target_close() -> void:
	var nearest_enemy = null
	var min_distance := INF
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
			
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_enemy = enemy
	
	closest_enemy = nearest_enemy

func shoot(delta: float) -> void:
	if not bullet_scene:
		return
	
	fire_timer += delta
	
	if fire_timer >= 1.0 / fire_rate:
		if closest_enemy and is_instance_valid(closest_enemy):
			spawn_bullet()
			fire_timer = 0.0

func spawn_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	
	var direction = (closest_enemy.global_position - global_position).normalized()
	bullet.setup(direction, damage, projectile_speed, self, pierce, damage_type)

func _on_bullet_damage_dealt(amount: int) -> void:
	total_damage_dealt += amount
	
	var tower_info = get_tree().current_scene.get_node_or_null("Tower Info")
	if not tower_info:
		tower_info = get_tree().current_scene.get_node_or_null("TowerInfo")
	
	if tower_info and tower_info.is_visible():
		if tower_info.has_method("update_damage_label") and tower_info.current_tower == self:
			tower_info.update_damage_label(total_damage_dealt)

func _on_enemy_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_in_range.append(area)

func _on_enemy_exited(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_in_range.erase(area)
		
		if closest_enemy == area:
			closest_enemy = null

func _on_mouse_entered() -> void:
	is_hovered = true

func _on_mouse_exited() -> void:
	is_hovered = false

func _on_click_area_input(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_clicked()

func on_clicked() -> void:
	if not is_placed:
		print("Tower not placed, cannot click")
		return
	
	print("Tower clicked! Searching for Tower Info...")
	
	var tower_info = get_tree().current_scene.get_node_or_null("Tower Info")
	if not tower_info:
		tower_info = get_tree().current_scene.get_node_or_null("TowerInfo")
	if not tower_info:
		for child in get_tree().current_scene.get_children():
			if "tower" in child.name.to_lower() and "info" in child.name.to_lower():
				tower_info = child
				break
	
	if not tower_info:
		print("ERROR: Tower Info not found! Available nodes:")
		for node in get_tree().current_scene.get_children():
			print("  - ", node.name, " (", node.get_class(), ")")
		return
	
	print("Found Tower Info: ", tower_info.name)
	tower_info.hide_info()
	set_selected(true)
	tower_info.show_tower_info(self)

func update_scale(delta: float) -> void:
	var target_scale = NORMAL_SCALE
	
	if is_selected:
		target_scale = SELECTED_SCALE
	elif is_hovered:
		target_scale = HOVER_SCALE
	
	if is_selected or (is_hovered and not is_selected):
		scale = scale.lerp(target_scale, 50.0 * delta)
	else:
		scale = target_scale

func _draw() -> void:
	if show_range:
		draw_circle(Vector2.ZERO, detection_range, Color(1, 1, 0, 0.2))
		draw_arc(Vector2.ZERO, detection_range, 0, TAU, 64, Color(1, 1, 0, 0.6), 2.0)

func update_detection_range() -> void:
	if not is_inside_tree():
		return
	
	var collision_shape = get_node_or_null("Area2D/CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = detection_range
	
	queue_redraw()

func set_preview_mode(is_preview_mode: bool) -> void:
	is_preview = is_preview_mode
	show_range = is_preview_mode
	is_placed = false
	queue_redraw()

func set_selected(selected: bool) -> void:
	is_selected = selected
	show_range = selected
	queue_redraw()

func finalize_placement() -> void:
	is_placed = true
	is_preview = false
	show_range = false
	queue_redraw()

func set_focus_mode(mode: FocusMode) -> void:
	focus_mode = mode
	update_closest_enemy()

func get_focus_mode_name() -> String:
	match focus_mode:
		FocusMode.FIRST:
			return "First"
		FocusMode.LAST:
			return "Last"
		FocusMode.STRONG:
			return "Strong"
		FocusMode.CLOSE:
			return "Close"
	
	return "Unknown"

func get_tower_name() -> String:
	return tower_name
