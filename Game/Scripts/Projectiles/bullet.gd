extends Area2D

enum DamageType{BASIC, EXPLOSION, FREEZE}

var tower_owner: Node = null
var velocity: = Vector2.ZERO
var damage: = 0
var damage_type: = DamageType.BASIC
var pierce: = 1
var hit_enemies: Array = []
var is_active: = true
var max_travel_distance: = 200.0
var _distance_tavelled = 0.0
var boss_bonus: = 0
var explosion_radius: = 0.0

const HIT_RADIUS: = 12.0

func _ready() -> void :
    pass

func setup(
    direction: Vector2, 
    bullet_damage: int, 
    bullet_speed: float, 
    owner_tower: Node, 
    bullet_pierce: int = 1, 
    bullet_damage_type: DamageType = DamageType.BASIC, 
    bullet_max_travel_distance: float = 200.0, 
    boss_damage_bonus: int = 0, 
    radius: float = 0.0
) -> void :
    velocity = direction.normalized() * bullet_speed
    damage = bullet_damage
    damage_type = bullet_damage_type
    rotation = direction.angle()
    tower_owner = owner_tower
    explosion_radius = radius
    pierce = bullet_pierce
    boss_bonus = boss_damage_bonus
    hit_enemies.clear()
    is_active = true
    max_travel_distance = bullet_max_travel_distance
    _distance_tavelled = 0.0

    SoundManager.play_random_pitch("crossbow_shoot(tower)")



func _process(delta: float) -> void :
    if not is_active:
        return
    position += velocity * delta
    var step = velocity * delta
    _distance_tavelled += step.length()
    if max_travel_distance > 0.0 and _distance_tavelled >= max_travel_distance:

        _destroy_bullet()
        return
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        if enemy.path_follow in hit_enemies:
            continue
        var dist = global_position.distance_to(enemy.global_position)
        if dist <= HIT_RADIUS:
            _hit_enemy(enemy)
            return
    if position.length() > 2000:
        queue_free()

func _hit_enemy(area: Area2D) -> void :
    if area.has_method("take_damage"):
        var dealer = tower_owner if is_instance_valid(tower_owner) else null
        hit_enemies.append(area.path_follow)
        if damage_type == DamageType.EXPLOSION and explosion_radius > 0.0:
            _explode()
            return
        var actual_damage = damage + (boss_bonus if area.get("is_boss") == true else 0)
        area.take_damage(actual_damage, dealer, damage_type)
    pierce -= 1
    if pierce <= 0:
        _destroy_bullet()

func _explode() -> void :
    var enemies = get_tree().get_nodes_in_group("enemies")
    var hits: = 0
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        if enemy in hit_enemies:
            continue
        if global_position.distance_to(enemy.global_position) <= explosion_radius:
            var dealer = tower_owner if is_instance_valid(tower_owner) else null
            enemy.take_damage(damage, dealer, damage_type)
            hit_enemies.append(enemy)
            hits += 1
            if hits >= pierce - 1:
                break
    _show_explosion()
    SoundManager.play_random_pitch("bomb_explode(tower)")
    _destroy_bullet()

func _show_explosion() -> void :
    var circle = Node2D.new()
    circle.z_index = 5
    get_parent().add_child(circle)
    circle.global_position = global_position
    var tween = circle.create_tween()
    tween.tween_method(
        func(r): circle.queue_redraw();circle.set_meta("r", r), 
        0.0, explosion_radius, 0.3
    )
    tween.parallel().tween_method(
        func(a): circle.set_meta("a", a), 
        0.8, 0.0, 0.3
    )
    tween.tween_callback(circle.queue_free)
    circle.draw.connect( func():
        var r = circle.get_meta("r", 0.0)
        var a = circle.get_meta("a", 0.8)
        circle.draw_circle(Vector2.ZERO, r, Color(1.0, 0.9, 0.0, a * 0.4))
        circle.draw_arc(Vector2.ZERO, r, 0, TAU, 32, Color(1.0, 0.7, 0.0, a), 2.0)
    )

func _destroy_bullet() -> void :
    is_active = false
    queue_free()
