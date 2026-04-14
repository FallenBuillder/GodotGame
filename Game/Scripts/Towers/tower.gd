extends Node2D

enum FocusMode { FIRST, LAST, CLOSE, STRONG }

@export var detection_range := 300.0:
	set(value):
		detection_range = value
		update_detection_range()

@export var tower_name := "Tower"
@export var tower_id := 0
@export var show_in_collection := true
@export var unlocked := false
@export var fire_rate := 1.0
@export var damage := 25
@export var damage_type := 0
@export var pierce := 1
@export var projectile_speed := 500
@export var cost := 100
@export var bullet_scene: PackedScene
@export var can_detect_camo := false
@export var is_not_farm := true
@export var can_attack_frozen := false
@export var upgrades: Array[TowerUpgradeData] = []
@export var max_projectile_travel_distance := 200.0
@export var crit_every_n_shots: int = 0
@export var crit_damage: int = 50
@export var boss_damage_bonus := 0
@export var can_pop_lead := false
@export var explosion_radius := 0.0

@export var farm_income := 20
@export var farm_times_per_wave := 4

@export var slowed_enemies_after_unfreeze := false
@export var freeze_layers: int = 0
@export var freeze_time := 1.43
@export var slowed_in_range := false
@export var apply_frost := false
@export var frost_every_n_seconds := 0.0
@export var always_show_range := false

@export var sentry_scene: PackedScene
@export var sentry_interval := 0.0
@export var sentry_lifetime := 0.0
var _sentry_timer := 0.0
var sentry_expert := false

@export var foam_scene: PackedScene
@export var foam_interval := 0.0
@export var foam_lifetime := 0.0
@export var foam_capacity := 0
var _foam_timer := 0.0

@export var trap_scene: PackedScene
@export var trap_interval := 0.0
@export var trap_rbe_capacity := 0
var _trap_timer := 0.0
var _active_trap: Node = null

var focus_mode: FocusMode = FocusMode.FIRST
var closest_enemy = null
var enemies_in_range: Array = []
var total_damage_dealt := 0
var total_spent := 0
var current_upgrade_level: int = -1

var has_proximity_bonus := false
var proximity_max_bonus_pct := 0.0
var _damage_taken_burst := false
var _damage_taken_timer := 0.0
const DAMAGE_TAKEN_BURST_DURATION := 7.0
const DAMAGE_TAKEN_BURST_MULTIPLIER := 4.0
var _shot_counter: int = 0
var check_timer := 0.0
var fire_timer := 0.0
var _farm_timer := 0.0
var _farm_interval := 0.0
var _farm_payouts_done := 0

var show_range := false
var is_selected := false
var is_hovered := false
var is_placed := false
var is_preview := false

var _freeze_pulse_timer := 0.0
const FREEZE_PULSE_DURATION := 0.4
const FREEZE_DURATION := 1.43

var sentry_damage: int = 0
var sentry_fire_rate: float = 0.0
var sentry_range: float = 0.0
var sentry_pierce: int = 0

var sentry_sprite_idle: Texture2D = null
var sentry_sprite_shoot: Texture2D = null
var sentry_bullet_scene: PackedScene = null

const CHECK_INTERVAL = 0.2
const HOVER_SCALE := Vector2(1.2, 1.2)
const SELECTED_SCALE := Vector2(1.25, 1.25)
const NORMAL_SCALE := Vector2(1.0, 1.0)

func _ready() -> void:
	add_to_group("towers")
	update_detection_range()
	var anim = get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.animation_finished.connect(_on_shoot_anim_done)
		anim.play("idle")
	if not is_not_farm and is_placed:
		_setup_farm()
	GameManager.damage_taken.connect(_on_damage_taken)

func _on_damage_taken() -> void:
	if not is_placed:
		return
	_damage_taken_burst = true
	_damage_taken_timer = DAMAGE_TAKEN_BURST_DURATION

func _get_effective_fire_rate() -> float:
	var rate := fire_rate

	if has_proximity_bonus and proximity_max_bonus_pct > 0.0:
		var best_ratio := 0.0
		for enemy in enemies_in_range:
			if not is_instance_valid(enemy):
				continue
			if enemy.path_follow:
				best_ratio = maxf(best_ratio, enemy.path_follow.progress_ratio)
		var speed_mult = 1.0 + proximity_max_bonus_pct * best_ratio
		rate /= speed_mult

	if _damage_taken_burst:
		rate /= DAMAGE_TAKEN_BURST_MULTIPLIER

	return maxf(rate, 0.05)

func apply_upgrade(upgrade: TowerUpgradeData) -> void:
	for change in upgrade.stat_changes:
		var stat: String = change.stat
		var value = change.value
		var mode: String = StatChange.Mode.keys()[change.mode].to_lower()
		match stat:
			"damage":
				match mode:
					"add": damage += value
					"set": damage = value
					"multiply": damage = int(damage * value)
			"fire_rate":
				match mode:
					"add": fire_rate += value
					"set": fire_rate = value
					"multiply": fire_rate *= value
			"range":
				match mode:
					"add": detection_range += value
					"set": detection_range = value
					"multiply": detection_range *= value
			"pierce":
				match mode:
					"add": pierce += value
					"set": pierce = value
					"multiply": pierce = int(pierce * value)
			"projectile_speed":
				match mode:
					"add": projectile_speed += value
					"set": projectile_speed = value
					"multiply": projectile_speed = int(projectile_speed * value)
			"farm_income":
				match mode:
					"add": farm_income += value
					"set": farm_income = value
					"multiply": farm_income = int(farm_income * value)
			"farm_times_per_wave":
				match mode:
					"add": farm_times_per_wave += value
					"set": farm_times_per_wave = value
					"multiply": farm_times_per_wave = int(farm_times_per_wave & value)
			"travel_distance":
				match mode:
					"add": max_projectile_travel_distance += value
					"set": max_projectile_travel_distance = value
					"multiply": max_projectile_travel_distance *= value
			"crit_shots":
				match mode:
					"add": crit_every_n_shots += int(value)
					"set": crit_every_n_shots = int(value)
			"crit_damage":
				match mode:
					"add": crit_damage += int(value)
					"set": crit_damage = int(value)
					"multiply": crit_damage = int(crit_damage * value)
			"boss_damage":
				match mode:
					"add": boss_damage_bonus += int(value)
					"set": boss_damage_bonus = int(value)
					"multiply": boss_damage_bonus = int(crit_damage * value)
			"explosion_radius":
				match mode:
					"add": explosion_radius += int(value)
					"set": explosion_radius = int(value)
					"multiply": explosion_radius = int(crit_damage * value)
			"proximity_bonus":
				has_proximity_bonus = bool(value)
			"proximity_max_pct":
				match mode:
					"add": proximity_max_bonus_pct += value
					"set": proximity_max_bonus_pct = value
			"lead":
				can_pop_lead = bool(value)
			"camo":
				can_detect_camo = bool(value)
			"frozen":
				can_attack_frozen = bool(value)
			"slowed_after_unfreeze":
				slowed_enemies_after_unfreeze = bool(value)
			"freeze_layers":
				match mode:
					"add": freeze_layers += int(value)
					"set": freeze_layers = int(value)
			"freeze_time":
				match mode:
					"add": freeze_time += value
					"set": freeze_time = value
					"multiply": freeze_time *= value
					"slowed_in_range": slowed_in_range = bool(value)
			"apply_frost":
				apply_frost = bool(value)
			"slowed_in_range":
				slowed_in_range = bool(value)
			"show_range":
				always_show_range = bool(value)
				queue_redraw()
			"sentry_damage":
				match mode:
					"add": sentry_damage += int(value)
					"set": sentry_damage = int(value)
			"sentry_fire_rate":
				match mode:
					"add": sentry_fire_rate += value
					"set": sentry_fire_rate = value
			"sentry_range":
				match mode:
					"add": sentry_range += value
					"set": sentry_range = value
			"sentry_pierce":
				match mode:
					"add": sentry_pierce += int(value)
					"set": sentry_pierce = int(value)
			"sentry_interval":
				match mode:
					"add": sentry_interval += value
					"set": sentry_interval = value
					"multiply": sentry_interval *= value
			"sentry_lifetime":
				match mode:
					"add": sentry_lifetime += value
					"set": sentry_lifetime = value
			"foam_interval":
				match mode:
					"add": foam_interval += value
					"set": foam_interval = value
			"foam_lifetime":
				match mode:
					"add": foam_lifetime += value
					"set": foam_lifetime = value
			"foam_capacity":
				match mode:
					"add": foam_capacity += int(value)
					"set": foam_capacity = int(value)
			"trap_interval":
				match mode:
					"add": trap_interval += value
					"set": trap_interval = value
			"trap_rbe":
				match mode:
					"add": trap_rbe_capacity += int(value)
					"set": trap_rbe_capacity = int(value)
			"sentry_scene":
				if change.get("scene_value"):
					sentry_scene = change.scene_value
			"foam_scene":
				if change.get("scene_value"):
					foam_scene = change.scene_value
			"trap_scene":
				if change.get("scene_value"):
					trap_scene = change.scene_value
	
	if upgrade.sentry_sprite_idle:
		sentry_sprite_idle = upgrade.sentry_sprite_idle
	if upgrade.sentry_sprite_shoot:
		sentry_sprite_shoot = upgrade.sentry_sprite_shoot
	if upgrade.unlock_sentry_scene:
		sentry_scene = upgrade.unlock_sentry_scene
	if upgrade.unlock_foam_scene:
		foam_scene = upgrade.unlock_foam_scene
	if upgrade.unlock_trap_scene:
		trap_scene = upgrade.unlock_trap_scene
	if upgrade.sentry_bullet_scene:
		sentry_bullet_scene = upgrade.sentry_bullet_scene
	if upgrade.sentry_expert_mode:
		sentry_expert = true
	
	if upgrade.new_tower_sprite_idle or upgrade.new_tower_sprite_shoot:
		var anim = get_node_or_null("AnimatedSprite2D")
		if anim and anim.sprite_frames:
			var frames = anim.sprite_frames.duplicate()
			if upgrade.new_tower_sprite_idle and frames.has_animation("idle"):
				frames.clear("idle")
				frames.add_frame("idle", upgrade.new_tower_sprite_idle)
			if upgrade.new_tower_sprite_shoot and frames.has_animation("shoot"):
				frames.clear("shoot")
				frames.add_frame("shoot", upgrade.new_tower_sprite_shoot)
			anim.sprite_frames = frames
	
	if upgrade.new_bullet_scene:
		bullet_scene = upgrade.new_bullet_scene
	
	total_spent += upgrade.cost
	current_upgrade_level += 1
	update_detection_range()

func _setup_farm() -> void:
	if farm_times_per_wave <= 0:
		return
	WaveManager.wave_started.connect(_on_wave_started_farm)

func _on_wave_started_farm(_wave_num: int) -> void:
	_farm_payouts_done = 0
	var wave_dur = WaveManager.get_wave_duration()
	if wave_dur > 0.0 and farm_times_per_wave > 0:
		_farm_interval = wave_dur / float(farm_times_per_wave)
	else:
		_farm_interval = 8.0
	_farm_timer = _farm_interval

func _physics_process(delta: float) -> void:
	if not is_placed:
		return
	if is_not_farm:
		turn(delta)
		shoot(delta)
		_tick_frost(delta)
		_tick_sentry(delta)
		_tick_foam(delta)
		_tick_trap(delta)
		if slowed_in_range:
			_tick_slow_in_range()
	else:
		_farm_tick(delta)
	_update_hover()
	update_scale(delta)
	if _freeze_pulse_timer > 0:
		_freeze_pulse_timer -= delta
		queue_redraw()

func _tick_sentry(delta: float) -> void:
	if not sentry_scene or sentry_interval <= 0.0:
		return
	_sentry_timer += delta
	if _sentry_timer >= sentry_interval:
		_sentry_timer = 0.0
		_spawn_sentry()

func _spawn_sentry() -> void:
	if not GameManager.level_node:
		return
	var sentry = sentry_scene.instantiate()
	var effective_damage_type := damage_type
	if sentry_expert:
		effective_damage_type = randi() % 3
	GameManager.level_node.add_child(sentry)
	var placed_pos = _find_valid_sentry_position()
	sentry.global_position = placed_pos
	if sentry.has_method("setup"):
		sentry.setup(sentry_lifetime, sentry_damage, sentry_fire_rate, sentry_range, sentry_pierce, sentry_bullet_scene, sentry_sprite_idle, sentry_sprite_shoot, effective_damage_type)

func _find_valid_sentry_position() -> Vector2:
	var level = GameManager.level_node
	var path_map = level.get_node_or_null("TileMapPath")
	for _attempt in range(30):
		var angle = randf() * TAU
		var dist = randf() * (detection_range if detection_range > 0 else 100.0)
		var candidate = global_position + Vector2(cos(angle), sin(angle)) * dist
		if path_map:
			var cell = path_map.local_to_map(path_map.to_local(candidate))
			if path_map.get_cell_source_id(cell) != -1:
				continue
		var overlap = false
		for tower in get_tree().get_nodes_in_group("towers"):
			if not tower.get("is_placed"):
				continue
			var shape_node = tower.get_node_or_null("ClickArea/CollisionShape2D")
			var radius = 20.0
			if shape_node and shape_node.shape is CircleShape2D:
				radius = shape_node.shape.radius
			if candidate.distance_to(tower.global_position) < radius + 12.0:
				overlap = true
				break
		if not overlap:
			return candidate
	return global_position

func _tick_foam(delta: float) -> void:
	if not foam_scene or foam_interval <= 0.0:
		return
	_foam_timer += delta
	if _foam_timer >= foam_interval:
		_foam_timer = 0.0
		_spawn_foam()

func _spawn_foam() -> void:
	if not WaveManager.current_path or not GameManager.level_node:
		return
	var path = WaveManager.current_path
	var best_progress := -1.0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or not enemy.path_follow:
			continue
		var d = global_position.distance_to(enemy.global_position)
		if d <= detection_range and enemy.path_follow.progress > best_progress:
			best_progress = enemy.path_follow.progress
	if best_progress < 0.0:
		return
	var foam = foam_scene.instantiate()
	GameManager.level_node.add_child(foam)
	foam.global_position = path.to_global(path.curve.sample_baked(best_progress))
	if foam.has_method("setup"):
		foam.setup(foam_lifetime, foam_capacity, can_pop_lead)

func _tick_trap(delta: float) -> void:
	if not trap_scene or trap_interval <= 0.0:
		return
	if _active_trap and is_instance_valid(_active_trap):
		return
	_trap_timer += delta
	if _trap_timer >= trap_interval:
		_trap_timer = 0.0
		_spawn_trap()

func _spawn_trap() -> void:
	if not WaveManager.current_path or not GameManager.level_node:
		return
	var trap = trap_scene.instantiate()
	var path = WaveManager.current_path
	var point = path.curve.sample_baked(path.curve.get_baked_length() * 0.5)
	GameManager.level_node.add_child(trap)
	trap.global_position = path.to_global(point)
	if trap.has_method("setup"):
		trap.setup(trap_rbe_capacity, GameManager.wave)
	_active_trap = trap
	trap.tree_exited.connect(func(): _active_trap = null, CONNECT_ONE_SHOT)

func _tick_frost(_delta: float) -> void:
	if not apply_frost:
		return
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy) or not enemy.get("is_frozen"):
			continue
		for other in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(other) or other == enemy:
				continue
			if other.get("is_frozen"):
				continue
			if other.global_position.distance_to(enemy.global_position) <= 20.0:
				other.apply_freeze(freeze_time, slowed_enemies_after_unfreeze)

func _tick_slow_in_range() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var in_range = detection_range < 0 or global_position.distance_to(enemy.global_position) <= detection_range
		if in_range and enemy.has_method("apply_slow"):
			enemy.apply_slow()
		elif not in_range and enemy.has_method("remove_slow"):
			enemy.remove_slow()

func _farm_tick(delta: float) -> void:
	if farm_times_per_wave <= 0:
		return
	if not WaveManager.is_running:
		return
	if _farm_interval <= 0.0:
		_farm_interval = 8.0
	_farm_timer -= delta
	if _farm_timer <= 0.0 and _farm_payouts_done < farm_times_per_wave:
		_farm_timer = _farm_interval
		_farm_payouts_done += 1
		GameManager.add_money(farm_income)
		_show_farm_popup(farm_income)

func _show_farm_popup(amount: int) -> void:
	var label = Label.new()
	label.text = "+$%d" % amount
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	label.add_theme_font_size_override("font_size", 14)
	label.z_index = 10
	GameManager.level_node.add_child(label)
	label.global_position = global_position + Vector2(-20, -30)
	var tween = label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 30, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

func _update_hover() -> void:
	var click_area = get_node_or_null("ClickArea")
	if not click_area:
		is_hovered = false
		return
	var shape = click_area.get_node_or_null("CollisionShape2D")
	if shape and shape.shape is CircleShape2D:
		is_hovered = global_position.distance_to(get_global_mouse_position()) <= shape.shape.radius
	else:
		is_hovered = false

func _can_target(enemy: Area2D) -> bool:
	if not is_instance_valid(enemy):
		return false
	if enemy.get("camo") == true and not can_detect_camo:
		return false
	if not can_attack_frozen and enemy.get("is_frozen") == true:
		return false
	if not can_pop_lead and enemy.get("damage_immunities") and 0 in enemy.damage_immunities:
		return false
	return true

func turn(delta: float) -> void:
	check_timer += delta
	if check_timer >= CHECK_INTERVAL:
		check_timer = 0.0
		_poll_enemies_in_range()
		update_closest_enemy()
	if closest_enemy and is_instance_valid(closest_enemy):
		if closest_enemy not in enemies_in_range:
			closest_enemy = null
			return
		look_at(closest_enemy.global_position)
		rotation -= PI / 2.0

func _poll_enemies_in_range() -> void:
	enemies_in_range.clear()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if not _can_target(enemy):
			continue
		var in_range = detection_range < 0 or global_position.distance_to(enemy.global_position) <= detection_range
		if in_range:
			enemies_in_range.append(enemy)

func update_closest_enemy() -> void:
	if enemies_in_range.is_empty():
		closest_enemy = null
		return
	match focus_mode:
		FocusMode.FIRST:
			_target_first()
		FocusMode.LAST:
			_target_last()
		FocusMode.STRONG:
			_target_strong()
		FocusMode.CLOSE:
			_target_close()

func _target_first() -> void:
	var furthest_enemy = null
	var max_progress := -1.0
	for enemy in enemies_in_range:
		if not _can_target(enemy): continue
		if not enemy.path_follow: continue
		if enemy.path_follow.progress_ratio > max_progress:
			max_progress = enemy.path_follow.progress_ratio
			furthest_enemy = enemy
	closest_enemy = furthest_enemy

func _target_last() -> void:
	var last_enemy = null
	var min_progress := 2.0
	for enemy in enemies_in_range:
		if not _can_target(enemy): continue
		if not enemy.path_follow: continue
		if enemy.path_follow.progress_ratio < min_progress:
			min_progress = enemy.path_follow.progress_ratio
			last_enemy = enemy
	closest_enemy = last_enemy

func _target_strong() -> void:
	var strongest_enemy = null
	var max_type := -1
	for enemy in enemies_in_range:
		if not _can_target(enemy): continue
		if enemy.enemy_id > max_type:
			max_type = enemy.enemy_id
			strongest_enemy = enemy
	closest_enemy = strongest_enemy

func _target_close() -> void:
	var nearest_enemy = null
	var min_distance := INF
	for enemy in enemies_in_range:
		if not _can_target(enemy): continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_enemy = enemy
	closest_enemy = nearest_enemy

func shoot(delta: float) -> void:
	if not is_not_farm:
		return
		
	if _damage_taken_burst:
		_damage_taken_timer -= delta
		if _damage_taken_timer <= 0.0:
			_damage_taken_burst = false

	fire_timer += delta
	var effective_rate = _get_effective_fire_rate()
	if fire_timer >= effective_rate:
		fire_timer -= effective_rate
		if closest_enemy and is_instance_valid(closest_enemy):
			if damage_type == 2 and not bullet_scene:
				_do_freeze_pulse()
				fire_timer = 0.0
			elif projectile_speed < 0 and not bullet_scene:
				_instant_hit()
			elif bullet_scene:
				if projectile_speed < 0:
					_instant_hit()
				else:
					spawn_bullet()

func _do_freeze_pulse() -> void:
	var anim = get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("shoot")
	_freeze_pulse_timer = FREEZE_PULSE_DURATION
	queue_redraw()
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		var immunities = enemy.get("damage_immunities")
		if immunities != null and 2 in immunities:
			continue
		if freeze_layers > 0:
			enemy.set("frozen_layers_remaining", freeze_layers)
		if enemy.has_method("apply_freeze"):
			enemy.apply_freeze(freeze_time, slowed_enemies_after_unfreeze)
		if damage > 0 and enemy.has_method("take_damage"):
			enemy.take_damage(damage, self, damage_type)

func _instant_hit() -> void:
	if not closest_enemy or not is_instance_valid(closest_enemy):
		return
	if closest_enemy.has_method("take_damage"):
		closest_enemy.take_damage(damage, self, damage_type)
		_on_bullet_damage_dealt(damage)
	if tower_name == "Boxing Mouse":
		_show_air_push(closest_enemy.global_position)
	var anim = get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("shoot")
	if crit_every_n_shots > 0:
		_shot_counter += 1
		if _shot_counter >= crit_every_n_shots:
			_shot_counter = 0
			_do_crit()

func _show_air_push(target_pos: Vector2) -> void:
	if not GameManager.level_node:
		return

	var dir := (target_pos - global_position).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var duration := 0.18

	for i in range(3):
		var vfx := Node2D.new()
		vfx.global_position = global_position
		vfx.z_index = 5
		GameManager.level_node.add_child(vfx)
	
		var delay := i * 0.045
		var wave_width := 18.0 + i * 8.0
		var wave_start := global_position + dir * (20.0 + i * 14.0)
		var wave_end := target_pos + dir * (i * 6.0)

		var t_ref := [0.0]

		var draw_func := func():
			var t: float = t_ref[0]
			var alpha := (1.0 - t) * 0.85
			var spread := wave_width * (0.4 + 0.6 * t)
			var thickness := 2.5 - t * 1.2
			var num_lines := 7
			for j in range(num_lines):
				var frac := float(j) / float(num_lines - 1) - 0.5
				var offset := perp * frac * spread * 2.0
				var wobble := sin(t * PI + frac * PI) * spread * 0.35
				var wobble_off := dir * wobble
				var line_start := offset - dir * (spread * 0.3)
				var line_end := offset + wobble_off + dir * (spread * 0.5)
				var fade := 1.0 - absf(frac) * 1.4
				fade = clampf(fade, 0.0, 1.0)
				vfx.draw_line(
					line_start,
					line_end,
					Color(0.85, 0.96, 1.0, alpha * fade),
					thickness * fade + 0.5
				)

		vfx.draw.connect(draw_func)

		var tween := vfx.create_tween()
		if delay > 0.0:
			tween.tween_interval(delay)
			tween.tween_callback(func(): vfx.modulate.a = 1.0)
		tween.tween_method(func(t: float):
			t_ref[0] = t
			vfx.global_position = wave_start.lerp(wave_end, t)
			vfx.queue_redraw()
		, 0.0, 1.0, duration)
		tween.tween_callback(vfx.queue_free)

func spawn_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	GameManager.level_node.add_child(bullet)
	bullet.global_position = global_position
	var target_pos = _predict_enemy_position(closest_enemy)
	var direction = (target_pos - global_position).normalized()
	var travel = max_projectile_travel_distance
	if travel > 0.0:
		travel = maxf(travel, global_position.distance_to(target_pos) + 20.0)
	bullet.setup(direction, damage, projectile_speed, self, pierce, damage_type, travel, boss_damage_bonus, explosion_radius)
	var anim = get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("shoot")
	if crit_every_n_shots > 0:
		_shot_counter += 1
		if _shot_counter >= crit_every_n_shots:
			_shot_counter = 0
			_do_crit()
func _do_crit() -> void:
	if not closest_enemy or not is_instance_valid(closest_enemy):
		return
	if closest_enemy.has_method("take_damage"):
		closest_enemy.take_damage(crit_damage, self, damage_type)
		_on_bullet_damage_dealt(crit_damage)
		_show_crit_popup(closest_enemy.global_position)

func _show_crit_popup(pos: Vector2) -> void:
	var label = Label.new()
	label.text = "CRIT!"
	label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	label.add_theme_font_size_override("font_size", 18)
	label.z_index = 10
	GameManager.level_node.add_child(label)
	label.global_position = pos + Vector2(-20, -30)
	var tween = label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

func _predict_enemy_position(enemy: Node) -> Vector2:
	var to_enemy = enemy.global_position - global_position
	var dist = to_enemy.length()
	var travel_time = dist / float(projectile_speed)
	var enemy_speed = enemy.get("speed")
	if enemy_speed == null or not enemy.path_follow:
		return enemy.global_position
	var path = enemy.path_follow.get_parent()
	if not path or not path is Path2D:
		return enemy.global_position
	var current_progress = enemy.path_follow.progress
	var sample_ahead = path.curve.get_closest_point(
		path.curve.sample_baked(current_progress + enemy_speed * travel_time)
	)
	return path.to_global(sample_ahead)

func _on_shoot_anim_done() -> void:
	var anim = get_node_or_null("AnimatedSprite2D")
	if anim and anim.animation == &"shoot":
		anim.play("idle")

func _on_bullet_damage_dealt(amount: int) -> void:
	total_damage_dealt += amount
	var tower_info = GameManager.layout_node.get_node_or_null("Tower Info")
	if tower_info and tower_info.is_visible() and tower_info.has_method("update_damage_label") and tower_info.current_tower == self:
		tower_info.update_damage_label(total_damage_dealt)

func on_clicked() -> void:
	if not is_placed:
		return
	if not GameManager.layout_node:
		push_warning("Layout node not found in GameManager")
		return
	if GameManager.layout_node.has_method("show_tower_info"):
		set_selected(true)
		GameManager.layout_node.show_tower_info(self)
	else:
		push_warning("Layout node doesn't have show_tower_info method")

func update_scale(_delta: float) -> void:
	var target_scale = NORMAL_SCALE
	if is_selected:
		target_scale = SELECTED_SCALE
	elif is_hovered:
		target_scale = HOVER_SCALE
	scale = scale.lerp(target_scale, 15.0 * _delta)
	if show_range or always_show_range:
		queue_redraw()

func _draw() -> void:
	var draw_radius = (30.0 if detection_range < 0 else detection_range) / scale.x
	if always_show_range:
		draw_circle(Vector2.ZERO, draw_radius, Color(0.3, 0.7, 1.0, 0.06))
		draw_arc(Vector2.ZERO, draw_radius, 0, TAU, 64, Color(0.3, 0.7, 1.0, 0.5), 2.0)
	if show_range:
		draw_circle(Vector2.ZERO, draw_radius, Color(1.0, 1.0, 1.0, 0.08))
		draw_arc(Vector2.ZERO, draw_radius, 0, TAU, 64, Color(0.75, 0.75, 0.75, 0.6), 2.0)
	if _freeze_pulse_timer > 0:
		var alpha = _freeze_pulse_timer / FREEZE_PULSE_DURATION * 0.35
		draw_circle(Vector2.ZERO, draw_radius, Color(0.5, 0.85, 1.0, alpha))

func update_detection_range() -> void:
	if not is_inside_tree():
		return
	var collision_shape = get_node_or_null("Area2D/CollisionShape2D")
	if collision_shape:
		var new_shape = CircleShape2D.new()
		new_shape.radius = max(detection_range, 0.0)
		collision_shape.shape = new_shape
	queue_redraw()

func set_preview_mode(is_preview_mode: bool) -> void:
	is_preview = is_preview_mode
	show_range = is_preview_mode
	is_placed = false
	queue_redraw()

func set_selected(selected: bool) -> void:
	is_selected = selected
	show_range = selected
	queue_redraw()

func finalize_placement() -> void:
	is_placed = true
	is_preview = false
	show_range = false
	total_spent = cost
	update_detection_range()
	if not is_not_farm:
		_setup_farm()
	queue_redraw()

func set_focus_mode(mode: FocusMode) -> void:
	focus_mode = mode
	update_closest_enemy()

func get_focus_mode_name() -> String:
	match focus_mode:
		FocusMode.FIRST: return "First"
		FocusMode.LAST: return "Last"
		FocusMode.STRONG: return "Strong"
		FocusMode.CLOSE: return "Close"
	return "Unknown"

func get_tower_name() -> String:
	return tower_name
