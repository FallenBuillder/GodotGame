class_name tower extends Node2D

var enemies: Array

@warning_ignore("unused_signal")
signal shoot(pos: Vector2, direction: float , bullet_enum: Data.Bullet)

func _process(delta: float) -> void:
	print(enemies)

func _on_enemy_detection_area_area_entered(area: Area2D) -> void:
	if area not in enemies:
		enemies.append(area)

func _on_enemy_detection_area_area_exited(area: Area2D) -> void:
	if area in enemies:
		enemies.erase(area)
