extends Button

@onready var icon_rect = $IconRect
@onready var name_label = $NameLabel
@onready var cost_label = $CostLabel
@onready var progress_bar = $ProgressBar

var upgrade_data: TowerUpgradeData = null
var target_tower: Node = null

signal upgrade_purchased(tower, upgrade)
signal hovered(upgrade: TowerUpgradeData, mouse_pos: Vector2)
signal unhovered

const BAR_FILLED_COLOR := Color(0.2, 0.8, 0.2)
const BAR_EMPTY_COLOR := Color(0.25, 0.25, 0.25)
const UPGRADE_SLOTS := 4

func setup(tower: Node, upgrade: TowerUpgradeData) -> void:
	target_tower = tower
	upgrade_data = upgrade
	name_label.text = upgrade.upgrade_name
	cost_label.text = "$%d" % upgrade.cost
	if upgrade.icon:
		icon_rect.texture = upgrade.icon
	_build_progress_bar()
	_refresh_affordability()
	if not GameManager.money_changed.is_connected(_on_money_changed):
		GameManager.money_changed.connect(_on_money_changed)

func _ready() -> void:
	set_process(false)
	mouse_entered.connect(func(): 
		set_process(true))
	mouse_exited.connect(func():
		set_process(false)
		unhovered.emit())

func _process(delta: float) -> void:
	if is_hovered():
		hovered.emit(upgrade_data, get_global_mouse_position())

func _build_progress_bar() -> void:
	for child in progress_bar.get_children():
		child.queue_free()
	var filled = target_tower.current_upgrade_level + 1
	for i in UPGRADE_SLOTS:
		var segment = Panel.new()
		segment.size_flags_vertical = Control.SIZE_EXPAND_FILL
		segment.size_flags_horizontal = Control.SIZE_FILL
		segment.custom_minimum_size = Vector2(8, 0)
		var style = StyleBoxFlat.new()
		style.bg_color = BAR_FILLED_COLOR if i >= UPGRADE_SLOTS - filled else BAR_EMPTY_COLOR
		style.set_corner_radius_all(2)
		segment.add_theme_stylebox_override("panel", style)
		segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		progress_bar.add_child(segment)

func _on_money_changed(_amount) -> void:
	_refresh_affordability()

func _refresh_affordability() -> void:
	if not upgrade_data:
		return
	var can_afford = GameManager.money >= upgrade_data.cost
	disabled = not can_afford
	modulate = Color.WHITE if can_afford else Color(0.6, 0.6, 0.6, 1.0)

func _pressed() -> void:
	SoundManager.play_constant("UpgradeTower")
	if not upgrade_data or not target_tower:
		return
	if not GameManager.spend_money(upgrade_data.cost):
		return
	target_tower.apply_upgrade(upgrade_data)
	upgrade_purchased.emit(target_tower, upgrade_data)
	if target_tower.current_upgrade_level >= target_tower.upgrades.size() - 1:
		name_label.text = "Fully Upgraded"
		cost_label.text = ""
		disabled = true
		modulate = Color(0.6, 0.6, 0.6, 1.0)
	else:
		var next = target_tower.upgrades[target_tower.current_upgrade_level + 1]
		setup(target_tower, next)
