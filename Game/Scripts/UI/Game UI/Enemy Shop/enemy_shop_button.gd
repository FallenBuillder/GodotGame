extends Button

@export var enemy_scene: PackedScene
@export var enemy_name: String

func _ready() -> void:
	text = enemy_name
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if GameManager.level_node:
		GameManager.level_node.spawn_specific_enemy(enemy_scene)
