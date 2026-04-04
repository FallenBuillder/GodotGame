extends Area2D

enum DamageType { BASIC, EXPLOSION, FREEZE}

@export var enemy_name := "Enemy"
@export var enemy_id := 1
@export var speed := 150.0
@export var health := 100
@export var damage := 10
@export var regen := false
@export var camo := false
@export var unlocked := false


@export var damage_immunities: Array[DamageType] = []
@export var child_enemy_ids: Array[int] = []

var reward := 1
var heal_interval := 3

var path_follow: PathFollow2D
var last_damager: Node = null
var current_health := 1
var heal_timer := 0.0
var current_layer := 0

func _ready() -> void:
	add_to_group("enemies")
	
	current_health = health
	current_layer = _get_layer_for_id(enemy_id)

func setup(new_path_follow: PathFollow2D) -> void:
	path_follow = new_path_follow

func _process(delta: float) -> void:
	if not path_follow:
		return
		
	path_follow.progress += speed * delta
	
	if path_follow.progress_ratio >= 0.99:
		reach_end()

	if regen and current_health < health:
		heal_timer += delta
		if heal_timer >= heal_interval:
			heal_timer = 0.0
			_heal_one_layer()

func _heal_one_layer() -> void:
	var target_layer = current_layer - 1
	
	if target_layer < 0:
		current_health = health
		return
	
	var target_id = _get_id_for_layer(target_layer)
	if target_id <= 0:
		return
	
	var scene_path = _find_enemy_scene_by_id(target_id)
	if scene_path == "":
		return
		
	var enemy_scene = load(scene_path)
	if not enemy_scene:
		return
	
	var temp_enemy = enemy_scene.instantiate()
	var new_health = temp_enemy.health
	temp_enemy.queue_free()
	
	current_layer = target_layer
	health = new_health
	current_health = health
	
func _get_layer_for_id(id: int) -> int:
	return id - 1

func _get_id_for_layer(layer: int) -> int:
	return layer + 1

func reach_end() -> void:
	GameManager.take_damage(damage)
	queue_free()

func take_damage(
	amount: int, 
	dealer: Node = null,
	damage_type: int = DamageType.BASIC
) -> void:
	if damage_type in damage_immunities:
		return
	
	heal_timer = 0.0
	
	health -= amount
	last_damager = dealer
	
	if dealer and dealer.has_method("_on_bullet_damage_dealt"):
		dealer._on_bullet_damage_dealt(amount)
	
	if health <= 0:
		die()

func die() -> void:
	if not child_enemy_ids.is_empty():
		call_deferred("_spawn_child_enemies")
		
	GameManager.add_money(reward)
	queue_free()

func _spawn_child_enemies() -> void:
	var path2d = path_follow.get_parent() if path_follow else null
	if not path2d:
		push_warning("Could not find Path2D to spawn child enemy")
		return
		
	for child_id in child_enemy_ids:
		if child_id <= 0:
			continue
		
		var scene_path = _find_enemy_scene_by_id(child_id)
		if scene_path == "":
			push_warning("Could not find enemy scene for ID: ", child_id)
			continue
			
		var enemy_scene = load(scene_path)
		if not enemy_scene:
			push_warning("Failed to load enemy scene: ", scene_path)
			continue
			
		var child_enemy = enemy_scene.instantiate()
		var child_path_follow = PathFollow2D.new()
		
		path2d.add_child(child_path_follow)
		child_path_follow.add_child(child_enemy)
		
		child_path_follow.progress = path_follow.progress
		
		child_enemy.setup(child_path_follow)
		
func _get_child_id_from_index(index: int) -> int:
	if index < child_enemy_ids.size():
		return child_enemy_ids[index]
		
	if not child_enemy_ids.is_empty():
		return child_enemy_ids[index % child_enemy_ids.size()]
		
	return enemy_id - 1
	
func _find_enemy_scene_by_id(id: int) -> String:
	var dir = "res://Game/Scenes/Enemies/"
	var dir_access = DirAccess.open(dir)
	
	if not dir_access:
		push_warning("Could not open enemies directory: ", dir)
		return ""
		
	var files = dir_access.get_files()
	
	for file in files:
		if file.begins_with(str(id) + "_") and file.ends_with(".tscn"):
			return dir + file
			
	return ""
