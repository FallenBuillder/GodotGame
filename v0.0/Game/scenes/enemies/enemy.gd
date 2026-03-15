extends Area2D

var path_follow: PathFollow2D

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow
	path_follow.progress = 200
func _process(delta: float) -> void:
	path_follow.progress += 200 * delta
	if path_follow.progress_ratio >= 0.99:
		queue_free()
		#TODO lower the health of the base in HERE
		print('10 Damage was delt..')


func _on_area_entered(bullet: Area2D) -> void:
	bullet.queue_free()
