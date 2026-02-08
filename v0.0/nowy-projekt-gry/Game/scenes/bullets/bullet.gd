extends Area2D
var direction: Vector2
var speed := 1000


func setup(pos, angle , bullet_enum):
	position = pos
	direction = -Vector2.DOWN.rotated(angle)
	rotation = angle
func _process(delta: float):
	position += direction * speed * delta
