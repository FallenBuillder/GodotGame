extends Node

var preview_tower: Node2D = null
var _tower_scene: PackedScene = null
var _tower_cost: int = 0
var _has_left_shop := false

signal placement_started
signal placement_cancelled
signal placement_confirmed

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if preview_tower and is_instance_valid(preview_tower):
			preview_tower.queue_free()
		preview_tower = null

func start_preview(scene: PackedScene, cost: int) -> void:
	if preview_tower:
		cancel()
	if not GameManager.level_node:
		return
	_tower_scene = scene
	_tower_cost = cost
	_has_left_shop = false

	preview_tower = scene.instantiate()
	preview_tower.modulate = Color(1, 1, 1, 0.85)
	if preview_tower.has_method("set_preview_mode"):
		preview_tower.set_preview_mode(true)
	GameManager.level_node.add_child(preview_tower)
	preview_tower.global_position = _get_world_mouse()
	preview_tower.visible = false
	placement_started.emit()

func cancel() -> void:
	if preview_tower and is_instance_valid(preview_tower):
		preview_tower.queue_free()
	preview_tower = null
	_has_left_shop = false
	_tower_scene = null
	_tower_cost = 0
	placement_cancelled.emit()

func attempt_place() -> bool:
	if not preview_tower:
		return false
	if not is_valid_position():
		if SettingsManager.placement_mode == SettingsManager.PlacementMode.DRAG_AND_DROP:
			cancel()
		return false
	if not GameManager.spend_money(_tower_cost):
		return false
	preview_tower.modulate = Color.WHITE
	if preview_tower.has_method("set_preview_mode"):
		preview_tower.set_preview_mode(false)
	if preview_tower.has_method("finalize_placement"):
		preview_tower.finalize_placement()
	preview_tower = null
	_tower_scene = null
	_tower_cost = 0
	placement_confirmed.emit()
	return true

func _process(_delta: float) -> void:
	if not preview_tower:
		return
	if not GameManager.level_node:
		cancel()
		return

	if _is_over_cancel_zone():
		if _has_left_shop:
			cancel()
		return
		
	if not _has_left_shop:
		_has_left_shop = true
		preview_tower.visible = true

	preview_tower.global_position = _get_world_mouse()
	preview_tower.modulate = Color(1, 1, 1, 0.85) if is_valid_position() else Color(1, 0, 0, 0.5)

func _get_world_mouse() -> Vector2:
	if not GameManager.level_node:
		return Vector2.ZERO
	return GameManager.level_node.get_local_mouse_position()

func is_valid_position() -> bool:
	if not preview_tower or not GameManager.level_node:
		return false

	var level = GameManager.level_node

	var path_map = level.get_node_or_null("TileMapPath")
	if path_map:
		var cell = path_map.local_to_map(path_map.to_local(preview_tower.global_position))
		if path_map.get_cell_source_id(cell) != -1:
			return false

	for tower in get_tree().get_nodes_in_group("towers"):
		if tower == preview_tower:
			continue
		if not tower.get("is_placed"):
			continue
		var dist = preview_tower.global_position.distance_to(tower.global_position)
		if dist < _get_tower_radius(tower) + _get_tower_radius(preview_tower):
			return false

	return true

func _get_tower_radius(tower: Node) -> float:
	var shape_node = tower.get_node_or_null("ClickArea/CollisionShape2D")
	if shape_node and shape_node.shape is CircleShape2D:
		return shape_node.shape.radius
	return 20.0

func _is_over_cancel_zone() -> bool:
	var screen_pos = get_viewport().get_mouse_position()
	var layout = GameManager.layout_node
	if not layout:
		return false
	for node_name in ["Tower Shop", "Enemy Shop", "ShopInfoPanel", "Bottom Info"]:
		var node = layout.get_node_or_null(node_name)
		if node and node.visible and node.get_global_rect().has_point(screen_pos):
			return true
	var tower_info = layout.get_node_or_null("Tower Info")
	if tower_info and tower_info.visible and tower_info.get_global_rect().has_point(screen_pos):
		return true
	return false
