extends Button

@export var enemy_id: int = 1
@export var enemy_name: String = "Enemy"

const CAMO_MATERIAL = preload("res://Game/Scripts/Shaders/CamoMaterial.tres")

func _ready() -> void:
	pressed.connect(_on_pressed)
	_update_visuals()

	var name_label = get_node_or_null("NameLabel")
	if name_label:
		name_label.text = enemy_name

func _update_visuals(_toggled: bool = false) -> void:
	var camo_toggle = get_node_or_null("../../HBoxContainer/CamoToggle")
	var regen_toggle = get_node_or_null("../../HBoxContainer/RegenToggle")
	var is_camo = camo_toggle.button_pressed if camo_toggle else false
	var is_regen = regen_toggle.button_pressed if regen_toggle else false

	var scene_path = WaveManager.get_enemy_scene_path(enemy_id)
	if scene_path == "":
		return

	var scene = load(scene_path)
	if not scene:
		return
	var instance = scene.instantiate()

	var tex = get_node_or_null("Control/TextureRect")
	if tex:
		var sprite = instance.get_node_or_null("Sprite2D")
		if sprite:
			if is_regen:
				var regen_tex = instance.get("regen_texture")
				tex.texture = regen_tex if regen_tex else sprite.texture
			else:
				tex.texture = sprite.texture
		if is_camo and enemy_id < 12:
			tex.material = CAMO_MATERIAL.duplicate()
		else:
			tex.material = null

	instance.queue_free()

func _on_pressed() -> void:
	if not GameManager.level_node:
		return

	var camo_toggle = get_node_or_null("../../HBoxContainer/CamoToggle")
	var regen_toggle = get_node_or_null("../../HBoxContainer/RegenToggle")
	var is_camo = camo_toggle.button_pressed if camo_toggle else false
	var is_regen = regen_toggle.button_pressed if regen_toggle else false

	var scene_path = WaveManager.get_enemy_scene_path(enemy_id)
	if scene_path == "":
		return

	GameManager.level_node.spawn_specific_enemy(load(scene_path), is_camo, is_regen)
