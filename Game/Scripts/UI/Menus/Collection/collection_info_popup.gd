extends CanvasLayer

@onready var name_label = $Panel/VBoxContainer/Name
@onready var sprite_rect = $Panel/VBoxContainer/Sprite
@onready var stats_label = $Panel/VBoxContainer/Stats
@onready var close_button = $Panel/VBoxContainer/Close

func _ready() -> void:
	close_button.pressed.connect(queue_free)

func show_enemy_info(enemy: Node) -> void:
	name_label.text = enemy.get("enemy_name") if "enemy_name" in enemy else "Enemy"

	if enemy.has_node("Sprite2D"):
		sprite_rect.texture = enemy.get_node("Sprite2D").texture

	var stats_text = ""
	stats_text += "ID: %d\n" % enemy.enemy_id
	stats_text += "Health: %d\n" % enemy.max_health
	stats_text += "Speed: %d\n" % enemy.speed
	stats_text += "Damage: %d\n" % enemy.damage
	stats_text += "Reward: $%d\n" % enemy.reward

	stats_label.text = stats_text
