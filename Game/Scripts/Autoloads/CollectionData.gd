extends Node

var _built := false

var towers: Dictionary = {}
var enemies: Dictionary = {}

func _ready() -> void:
	call_deferred("_build_all")

func _build_all() -> void:
	if _built:
		return
	_built = true
	_build_tower_data()
	_build_enemy_data()

func ensure_built() -> void:
	if not _built:
		_build_all()

func _build_tower_data() -> void:
	var dir = "res://Game/Scenes/Towers/"
	var da = DirAccess.open(dir)
	if not da:
		return
	for fname in da.get_files():
		if not fname.ends_with(".tscn"):
			continue
		var scene = load(dir + fname)
		if not scene:
			continue
		var node = scene.instantiate()
		var tid = node.get("tower_id")
		if tid == null:
			node.queue_free()
			continue
		if node.get("show_in_collection") == false:
			node.queue_free()
			continue
		towers[tid] = {
			"tower_id": tid,
			"scene_path": dir + fname,
			"name": node.get("tower_name") if "tower_name" in node else "Tower",
			"unlocked": false,
			"sprite": _get_texture(node),
			"cost": node.get("cost") if "cost" in node else 0,
			"damage": node.get("damage") if "damage" in node else 0,
			"range": node.get("detection_range") if "detection_range" in node else 0,
			"fire_rate": node.get("fire_rate") if "fire_rate" in node else 0.0,
			"damage_type_name": ["Basic", "Explosion", "Freeze"][node.get("damage_type") if "damage_type" in node else 0],
			"pierce": node.get("pierce") if "pierce" in node else 1,
		}
		node.queue_free()

func _build_enemy_data() -> void:
	var dir = "res://Game/Scenes/Enemies/"
	var da = DirAccess.open(dir)
	if not da:
		return
	for fname in da.get_files():
		if not fname.ends_with(".tscn"):
			continue
		if "_camo" in fname or "_regen" in fname:
			continue
		var scene = load(dir + fname)
		if not scene:
			continue
		var node = scene.instantiate()
		var eid = node.get("enemy_id") if "enemy_id" in node else 0
		enemies[eid] = {
			"id": eid,
			"scene_path": dir + fname,
			"name": node.get("enemy_name") if "enemy_name" in node else "Enemy",
			"sprite": _get_texture(node),
			"health": node.get("health") if "health" in node else 0,
			"speed": node.get("speed") if "speed" in node else 0,
			"damage": node.get("damage") if "damage" in node else 0,
			"reward": node.get("reward") if "reward" in node else 1,
			"immunities": node.get("damage_immunities") if "damage_immunities" in node else [],
		}
		node.queue_free()

func _get_texture(node: Node) -> Texture2D:
	var s = node.get_node_or_null("Sprite2D")
	if s:
		return s.texture
	var a = node.get_node_or_null("AnimatedSprite2D")
	if a and a.sprite_frames:
		var frames = a.sprite_frames
		if frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
			return frames.get_frame_texture("idle", 0)
	return null
