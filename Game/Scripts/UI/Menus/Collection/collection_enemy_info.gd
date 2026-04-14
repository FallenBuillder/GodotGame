extends Control

@onready var sprite_rect = $Panel/VBoxContainer/Sprite
@onready var name_label = $Panel/VBoxContainer/Name
@onready var stats_label = $Panel/VBoxContainer/Stats
@onready var lore_label = $Panel/Lore
@onready var close_button = $Panel/Close

const DAMAGE_TYPE_NAMES := {0: "Basic", 1: "Explosion", 2: "Freeze"}

signal closed

func _ready() -> void:
	close_button.pressed.connect(_on_close)
	
func _on_close() -> void:
	closed.emit()
	queue_free()

func populate(data: Dictionary) -> void:
	name_label.text = data.get("name", "Enemy")
	sprite_rect.texture = data.get("sprite", null)
	var immunities = data.get("immunities", [])
	var imm_names: Array = []
	for i in immunities:
		imm_names.append(DAMAGE_TYPE_NAMES.get(i, "Unknown"))
	var imm_text = ", ".join(imm_names) if not imm_names.is_empty() else "None"
	var _stats = "Speed: %.1f\nDamage: %d\nImmunities: %s\nKilled: %d" % [
		data.get("speed", 0.0),
		data.get("damage", 0),
		imm_text,
		data.get("killed", 0)
	]
	stats_label.text = _stats
