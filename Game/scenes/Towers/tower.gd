extends Node2D
var closest_enemy = null
var check_timer = 0.0
var enemies_in_range = []
var fire_timer = 0.0
var show_range := false  # Only show during placement

@export var detection_range := 300.0:
	set(value):
		detection_range = value
		update_detection_range()

@export var fire_rate := 1.0
@export var damage := 25
@export var projectile_speed := 500
@export var cost := 100
@export var bullet_scene: PackedScene

const CHECK_INTERVAL = 0.2

func _ready():
	add_to_group("towers")
	
	$Area2D.area_entered.connect(_on_enemy_entered)
	$Area2D.area_exited.connect(_on_enemy_exited)
	
	update_detection_range()

func _draw():
	if show_range:
		# Draw filled circle with border
		draw_circle(Vector2.ZERO, detection_range, Color(1, 1, 0, 0.2))  # Yellow filled
		draw_arc(Vector2.ZERO, detection_range, 0, TAU, 64, Color(1, 1, 0, 0.6), 2.0)  # Yellow border

func update_detection_range():
	if not is_inside_tree():
		return
	
	var collision_shape = get_node_or_null("Area2D/CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = detection_range
	
	queue_redraw()

func set_preview_mode(is_preview: bool):
	show_range = is_preview
	queue_redraw()

func _physics_process(delta: float) -> void:
	turn(delta)
	shoot(delta)

func turn(delta):
	check_timer += delta
	
	if check_timer >= CHECK_INTERVAL:
		check_timer = 0.0
		update_closest_enemy()
	
	if closest_enemy and is_instance_valid(closest_enemy):
		var enemy_pos = closest_enemy.global_position
		look_at(enemy_pos)

func shoot(delta):
	if not bullet_scene:
		return
	
	fire_timer += delta
	
	if fire_timer >= 1.0 / fire_rate:
		if closest_enemy and is_instance_valid(closest_enemy):
			spawn_bullet()
			fire_timer = 0.0

func spawn_bullet():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	var direction = (closest_enemy.global_position - global_position).normalized()
	bullet.setup(direction, damage, projectile_speed)

func _on_enemy_entered(area):
	if area.is_in_group("enemies"):
		enemies_in_range.append(area)

func _on_enemy_exited(area):
	if area.is_in_group("enemies"):
		enemies_in_range.erase(area)
		if closest_enemy == area:
			closest_enemy = null

func update_closest_enemy():
	if enemies_in_range.is_empty():
		closest_enemy = null
		return
	
	var min_distance = INF
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
