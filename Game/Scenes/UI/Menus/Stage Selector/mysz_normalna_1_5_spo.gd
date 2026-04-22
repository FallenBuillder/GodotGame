extends Sprite2D


var rotation_speed = 2.0

func _process(delta):

    rotation += rotation_speed * delta
