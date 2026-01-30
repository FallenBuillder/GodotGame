extends tower

"""
func _process(_delta: float) -> void:
	if enemies.size() > 0:
		$Turret.look_at(enemies[0].global_position)
		$Turret.rotation -= PI
"""

func _process(_delta: float) -> void:
	if enemies.size() > 0:
		var target_pos = get_enemy_center(enemies[0])
		$Turret.look_at(target_pos)
		
		# If your sprite faces UP by default, use this offset:
		$Turret.rotation += deg_to_rad(90) 
		
		# If your sprite faces DOWN by default, use this:
		# $Turret.rotation -= deg_to_rad(90)
func get_enemy_center(area: Area2D) -> Vector2:
	var enemy := area.get_parent()
	return enemy.global_position
		
		
func _on_reload_timer_timeout() -> void:
	if enemies:
		var dir = -Vector2.DOWN.rotated($Turret.rotation).normalized()
		shoot.emit(position + dir * 16, $Turret.rotation , Data.Bullet.SINGLE)
