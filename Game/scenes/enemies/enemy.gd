extends Area2D
var path_follow: PathFollow2D

@export var speed := 150
@export var health := 100
@export var damage := 10
@export var reward := 50

func _ready():
	add_to_group("enemies")

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow

func _process(delta: float) -> void:
	if path_follow:
		path_follow.progress += speed * delta
		if path_follow.progress_ratio >= 0.99:
			reach_end()

func reach_end():
	GameManager.take_damage(damage)
	queue_free()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	GameManager.add_money(reward)
	queue_free()
