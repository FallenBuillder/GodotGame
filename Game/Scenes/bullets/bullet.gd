extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 25
var speed: float = 500

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	position += velocity * delta

func setup(direction: Vector2, bullet_damage: int, bullet_speed: float):
	velocity = direction.normalized() * bullet_speed
	damage = bullet_damage
	speed = bullet_speed
	rotation = direction.angle()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		# Damage the enemy
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()
