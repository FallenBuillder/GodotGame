extends Area2D

var lifetime: = 8.2
var capacity: = 30
var can_pop_lead: = false
var _timer: = 0.0
var _hit_enemies: Array = []

func setup(life: float, cap: int, lead: bool) -> void :
    lifetime = life
    capacity = cap
    can_pop_lead = lead
    monitoring = true
    call_deferred("_check_overlapping")

func _check_overlapping() -> void :
    for area in get_overlapping_areas().duplicate():
        _apply(area)

func _process(delta: float) -> void :
    _timer += delta
    if _timer >= lifetime:
        _cleanup()
        queue_free()

func _cleanup() -> void :
    for e in _hit_enemies:
        if is_instance_valid(e):
            var s = e.get_node_or_null("Sprite2D")
            if s: s.modulate = Color.WHITE

func _on_area_entered(area: Area2D) -> void :
    _apply(area)

func _apply(area: Area2D) -> void :
    if not area.is_in_group("enemies"):
        return
    if area in _hit_enemies:
        return
    _hit_enemies.append(area)
    var s = area.get_node_or_null("Sprite2D")
    if s:
        s.modulate = Color(0.5, 1.0, 0.5, 1.0)
    if area.get("camo") == true:
        area.set_camo(false)
    if area.get("regen") == true:
        area.set_regen(false)
    if can_pop_lead:
        var imm = area.get("damage_immunities")
        if imm != null and 0 in imm:
            area.damage_immunities.erase(0)
            area.take_damage(1, null, 0)
            if is_instance_valid(area):
                area.damage_immunities.append(0)

func _on_area_exited(area: Area2D) -> void :
    _hit_enemies.erase(area)
    if is_instance_valid(area):
        var s = area.get_node_or_null("Sprite2D")
        if s: s.modulate = Color.WHITE
