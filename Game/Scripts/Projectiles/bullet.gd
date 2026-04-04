extends Area2D

enum DamageType { BASIC, EXPLOSION, FREEZE}

signal damage_dealt(amount: int)

var tower_owner: Node = null
var velocity := Vector2.ZERO
var damage := 0
var damage_type := DamageType.BASIC
var pierce := 1
var hit_enemies: Array[Area2D] = []
var is_active := true

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	monitoring = false

func setup(
	direction: Vector2,
	bullet_damage: int,
	bullet_speed: float,
	owner_tower: Node,
	bullet_pierce: int = 1,
	bullet_damage_type: DamageType = DamageType.BASIC
) -> void:
	velocity = direction.normalized() * bullet_speed
	damage = bullet_damage
	damage_type = bullet_damage_type
	rotation = direction.angle()
	tower_owner = owner_tower
	pierce = bullet_pierce
	hit_enemies.clear()
	is_active = true

	call_deferred("_enable_monitoring")

func _enable_monitoring() -> void:
	monitoring = true

func _process(delta: float) -> void:
	if not is_active:
		return
		
	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if not is_active:
		return
		
	if not area.is_in_group("enemies"):
		return

	if area in hit_enemies:
		return

	if not is_instance_valid(area):
		return

	if area.has_method("take_damage"):
		area.take_damage(damage, tower_owner, damage_type)
		damage_dealt.emit(damage)
		hit_enemies.append(area)

		pierce -= 1

		if pierce <= 0:
			_destroy_bullet()

func _destroy_bullet() -> void:
	is_active = false
	set_deferred("monitoring", false)
	queue_free()
