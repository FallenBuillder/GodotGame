extends Area2D

enum DamageType { BASIC, EXPLOSION, FREEZE }

@export var enemy_name := "Enemy"
@export var enemy_id := 1
@export var speed := 150.0
@export var health := 100
@export var damage := 10
@export var regen := false
@export var camo := false
@export var unlocked := false
@export var regen_texture: Texture2D
@export var scale_locked := true
@export var is_boss := false

@export var damage_immunities: Array[DamageType] = []
@export var child_enemy_ids: Array[int] = []

var reward := 1

var path_follow: PathFollow2D
var last_damager: Node = null
var current_health := 0

var _regen_max_id := 0
var _regen_timer := 0.0
const REGEN_DELAY := 3.0

var is_child_spawn := false
var has_lost_layers := false
var is_frozen := false
var _freeze_timer := 0.0
var _base_speed := 0.0

var is_slowed := false
var _slow_sources: int = 0
const SLOW_MULTIPLIER := 0.25
var _slow_after_unfreeze := false
var frozen_layers_remaining: int = 0

const CAMO_MATERIAL = preload("res://Game/Scripts/Shaders/CamoMaterial.tres")
const FREEZE_TINT := Color(0.6, 0.85, 1.0, 1.0)

func _ready() -> void:
	set_notify_transform(false)
	add_to_group("enemies")
	current_health = health
	_base_speed = speed
	_regen_max_id = enemy_id
	z_index = 1
	z_as_relative = false
	_apply_camo_visual()
	if regen:
		_apply_regen_visual()

func setup(new_path_follow: PathFollow2D) -> void:
	path_follow = new_path_follow

func _process(delta: float) -> void:
	if not path_follow:
		return
	if is_frozen:
		_freeze_timer -= delta
		if _freeze_timer <= 0.0:
			_unfreeze()
	else:
		path_follow.progress += speed * delta
	if path_follow.progress_ratio >= 0.99:
		reach_end()
		return
	if regen and enemy_id < _regen_max_id:
		_regen_timer += delta
		if _regen_timer >= REGEN_DELAY:
			_regen_timer = 0.0
			_gain_layer()

func apply_slow() -> void:
	if is_slowed:
		return
	is_slowed = true
	_slow_sources += 1
	speed = _base_speed * SLOW_MULTIPLIER

func remove_slow() -> void:
	_slow_sources = maxi(_slow_sources - 1, 0)
	if _slow_sources == 0 and is_slowed:
		is_slowed = false
		speed = _base_speed

func pop_layers(layers: int) -> void:
	_pop_layers(layers)

func apply_freeze(duration: float, slow_after: bool = false) -> void:
	if is_boss:
		return
	if DamageType.FREEZE in damage_immunities:
		return
	is_frozen = true
	_freeze_timer = duration
	_slow_after_unfreeze = slow_after
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = FREEZE_TINT

func _unfreeze() -> void:
	is_frozen = false
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.WHITE
	if _slow_after_unfreeze:
		apply_slow()

func set_camo(value: bool) -> void:
	camo = value
	_apply_camo_visual()

func set_regen(value: bool) -> void:
	regen = value
	if regen:
		_regen_max_id = enemy_id
		_apply_regen_visual()
	else:
		var sprite = get_node_or_null("Sprite2D")
		var scene_path = WaveManager.get_enemy_scene_path(enemy_id)
		if sprite and scene_path != "":
			var ref = load(scene_path).instantiate()
			var ref_sprite = ref.get_node_or_null("Sprite2D")
			if ref_sprite:
				sprite.texture = ref_sprite.texture
			ref.queue_free()

func _apply_regen_visual() -> void:
	if not regen or not regen_texture:
		return
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.texture = regen_texture

func _apply_camo_visual() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
	if not camo or enemy_id >= 12:
		sprite.material = null
		return
	sprite.material = CAMO_MATERIAL.duplicate()

func reach_end() -> void:
	GameManager.take_damage(damage)
	queue_free()

func take_damage(amount: int, dealer: Node = null, damage_type: int = DamageType.BASIC) -> void:
	if damage_type in damage_immunities:
		return
	_regen_timer = 0.0
	last_damager = dealer
	current_health -= amount
	if dealer and dealer.has_method("_on_bullet_damage_dealt"):
		dealer._on_bullet_damage_dealt(amount)
	if current_health <= 0:
		die()

func _pop_layers(layers: int) -> void:
	has_lost_layers = true
	var target_id = enemy_id - layers
	if target_id <= 0:
		_die_fully()
	else:
		_apply_layer_data(target_id)

func _die_fully() -> void:
	if not has_lost_layers and not child_enemy_ids.is_empty():
		call_deferred("_spawn_child_enemies")
	ProgressManager.on_enemy_killed(enemy_id)
	GameManager.add_money(reward)
	queue_free()

func die() -> void:
	if not is_child_spawn and (regen or not child_enemy_ids.is_empty()) and enemy_id > 1:
		_lose_layer()
		return
	_die_fully()

func _lose_layer() -> void:
	has_lost_layers = true
	var carry = frozen_layers_remaining
	_apply_layer_data(enemy_id - 1)
	if carry > 0:
		frozen_layers_remaining = carry - 1
		apply_freeze(_freeze_timer if is_frozen else 1.43)

func _gain_layer() -> void:
	_apply_layer_data(enemy_id + 1)

func _apply_layer_data(target_id: int) -> void:
	var scene_path = WaveManager.get_enemy_scene_path(target_id)
	if scene_path == "":
		if target_id < enemy_id:
			ProgressManager.on_enemy_killed(enemy_id)
			GameManager.add_money(reward)
			queue_free()
		return
	var ref_scene = load(scene_path)
	if not ref_scene:
		return
	var ref = ref_scene.instantiate()
	health = ref.health
	current_health = ref.health
	damage = ref.damage
	speed = ref.speed
	_base_speed = ref.speed
	reward = ref.reward
	enemy_id = target_id
	_regen_timer = 0.0
	damage_immunities = ref.damage_immunities.duplicate()
	var ref_sprite = ref.get_node_or_null("Sprite2D")
	var own_sprite = get_node_or_null("Sprite2D")
	if ref_sprite and own_sprite:
		if regen and ref.regen_texture:
			own_sprite.texture = ref.regen_texture
		else:
			own_sprite.texture = ref_sprite.texture
	
	ref.queue_free()
	_apply_camo_visual()
	if regen:
		_apply_regen_visual()

func _spawn_child_enemies() -> void:
	var path2d = path_follow.get_parent() if path_follow else null
	if not path2d:
		return
	for child_id in child_enemy_ids:
		if child_id <= 0:
			continue
		var scene_path = WaveManager.get_enemy_scene_path(child_id)
		if scene_path == "":
			continue
		var enemy_scene = load(scene_path)
		if not enemy_scene:
			continue
		var child_enemy = enemy_scene.instantiate()
		if camo:
			child_enemy.set_camo(true)
		if regen:
			child_enemy.set_regen(true)
		child_enemy.is_child_spawn = true
		var child_path_follow = PathFollow2D.new()
		path2d.add_child(child_path_follow)
		child_path_follow.add_child(child_enemy)
		child_path_follow.progress = path_follow.progress
		child_enemy.setup(child_path_follow)
