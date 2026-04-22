extends Node2D

var lifetime: = 25.0
var _timer: = 0.0
var _fire_timer: = 0.0
var fire_rate: = 0.66
var range: = 290.0
var pierce: = 2
var damage: = 1
var _target = null
var damage_type: = 0

@export var nail_scene: PackedScene

func setup(life: float, dmg: int = 0, fr: float = 0.0, rng: float = 0.0, prc: int = 0, bullet: PackedScene = null, sprite_idle: Texture2D = null, sprite_shoot: Texture2D = null, dmg_type: int = 0) -> void :
    lifetime = life
    if dmg > 0: damage = dmg
    if fr > 0.0: fire_rate = fr
    if rng > 0.0: range = rng
    if prc > 0: pierce = prc
    if bullet: nail_scene = bullet
    damage_type = dmg_type
    var anim = get_node_or_null("AnimatedSprite2D")
    if anim and anim.sprite_frames and (sprite_idle or sprite_shoot):
        var frames = anim.sprite_frames.duplicate()
        if sprite_idle and frames.has_animation("idle"):
            frames.clear("idle")
            frames.add_frame("idle", sprite_idle)
        if sprite_shoot and frames.has_animation("shoot"):
            frames.clear("shoot")
            frames.add_frame("shoot", sprite_shoot)
        anim.sprite_frames = frames

func _process(delta: float) -> void :
    _timer += delta
    if _timer >= lifetime:
        queue_free()
        return
    _update_target()
    _fire_timer += delta
    if _fire_timer >= fire_rate:
        _fire_timer = 0.0
        _shoot()

func _update_target() -> void :
    if _target and is_instance_valid(_target):
        var d = global_position.distance_to(_target.global_position)
        if d <= range:
            return
    _target = null
    var best_dist: = INF
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(enemy):
            continue
        var d = global_position.distance_to(enemy.global_position)
        if d <= range and d < best_dist:
            best_dist = d
            _target = enemy

func _shoot() -> void :
    if not nail_scene or not GameManager.level_node or not _target or not is_instance_valid(_target):
        return
    look_at(_target.global_position)
    rotation -= PI / 2.0
    var bullet = nail_scene.instantiate()
    GameManager.level_node.add_child(bullet)
    bullet.global_position = global_position
    var dir = (_target.global_position - global_position).normalized()
    bullet.setup(dir, damage, 600.0, self, pierce, damage_type, 0.0)
    var anim = get_node_or_null("AnimatedSprite2D")
    if anim:
        anim.play("shoot")
