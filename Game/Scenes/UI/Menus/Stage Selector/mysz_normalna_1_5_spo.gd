extends Sprite2D

# Prędkość obrotu (w radianach na sekundę)
var rotation_speed = 2.0 

func _process(delta):
	# Obracamy o prędkość pomnożoną przez czas klatki
	rotation += rotation_speed * delta
