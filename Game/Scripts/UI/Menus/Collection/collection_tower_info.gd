extends Control

@onready var sprite_rect = $Panel/Sprite
@onready var name_label = $Panel/VBoxContainer/Name
@onready var cost_label = $Panel/VBoxContainer/Cost
@onready var damage_type_label = $Panel/VBoxContainer/DamageType
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
	name_label.text = data.get("name", "Tower")
	sprite_rect.texture = data.get("sprite", null)
	cost_label.text = "Cost: $%d" % data.get("cost", 0)
	var dtype = data.get("damage_type", 0)
	damage_type_label.text = "Damage Type: %s" % DAMAGE_TYPE_NAMES.get(dtype, "Basic")
	var stats = "Pierce: %d\nRange: %d" % [
		data.get("pierce", 0),
		data.get("range", 0),
	]
	stats_label.text = stats
	lore_label.text = data.get("lore", "")
