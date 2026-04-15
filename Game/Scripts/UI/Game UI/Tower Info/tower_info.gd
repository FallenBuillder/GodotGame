extends Control

@onready var tower_name_label = $Panel/VBoxContainer/TowerNameLabel
@onready var damage_label = $Panel/VBoxContainer/DamageLabel
@onready var focus_mode_label = $Panel/VBoxContainer/FocusModeContainer/FocusModeLabel
@onready var prev_focus_button = $Panel/VBoxContainer/FocusModeContainer/PrevButton
@onready var next_focus_button = $Panel/VBoxContainer/FocusModeContainer/NextButton
@onready var sell_button = $Panel/VBoxContainer/SellButton
@onready var upgrade_button = $Panel/UpgradeButton
@onready var upgrade_tooltip = $UpgradeToolTip

var current_tower: Node = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	sell_button.pressed.connect(_on_sell_pressed)
	prev_focus_button.pressed.connect(_on_prev_focus_pressed)
	next_focus_button.pressed.connect(_on_next_focus_pressed)

func _on_upgrade_hovered(upgrade: TowerUpgradeData, mouse_pos: Vector2) -> void:
	upgrade_tooltip.get_node("Label").text = upgrade.description
	if not upgrade_tooltip.visible:
		upgrade_tooltip.show()
		await get_tree().process_frame
	var mouse = get_global_mouse_position()
	upgrade_tooltip.global_position.x = mouse.x - upgrade_tooltip.size.x / 2.0

func _on_upgrade_unhovered() -> void:
	upgrade_tooltip.hide()

func show_tower_info(tower: Node) -> void:
	if current_tower and is_instance_valid(current_tower) and current_tower != tower:
		current_tower.set_selected(false)

	current_tower = tower
	tower.set_selected(true)

	tower_name_label.text = tower.tower_name
	damage_label.text = "Damage Dealt: %d" % tower.total_damage_dealt
	focus_mode_label.text = tower.get_focus_mode_name()
	sell_button.text = "Sell ($%d)" % int(tower.total_spent * 0.8)

	visible = true
	_refresh_upgrade(tower)
	show()

func _refresh_upgrade(tower: Node) -> void:
	var upgrades = tower.get("upgrades")
	var level = tower.get("current_upgrade_level")
	if not upgrades or upgrades.is_empty() or level == null or level >= upgrades.size() - 1:
		upgrade_button.show()
		upgrade_button.setup(tower, upgrades[upgrades.size() - 1])
		upgrade_button.disabled = true
		upgrade_button.modulate = Color(0.6, 0.6, 0.6, 1.0)
		upgrade_button.get_node("NameLabel").text = "Fully Upgraded"
		upgrade_button.get_node("CostLabel").text = ""
		return
	upgrade_button.show()
	upgrade_button.setup(tower, upgrades[level + 1])
	if not upgrade_button.upgrade_purchased.is_connected(_on_upgrade_purchased):
		upgrade_button.upgrade_purchased.connect(_on_upgrade_purchased)
	if upgrade_button.hovered.is_connected(_on_upgrade_hovered):
		upgrade_button.hovered.disconnect(_on_upgrade_hovered)
	if upgrade_button.unhovered.is_connected(_on_upgrade_unhovered):
		upgrade_button.unhovered.disconnect(_on_upgrade_unhovered)
	upgrade_button.hovered.connect(_on_upgrade_hovered)
	upgrade_button.unhovered.connect(_on_upgrade_unhovered)

func _on_upgrade_purchased(tower: Node, _upgrade: TowerUpgradeData) -> void:
	if tower == current_tower:
		show_tower_info(tower)

func hide_info() -> void:
	if current_tower and is_instance_valid(current_tower):
		current_tower.set_selected(false)
	current_tower = null
	hide()
	if GameManager.layout_node:
		var bottom = GameManager.layout_node.get_node_or_null("Bottom Info")
		if bottom:
			bottom.show()

func update_damage_label(new_damage: int) -> void:
	if is_visible() and current_tower:
		damage_label.text = "Damage Dealt: %d" % new_damage

func _on_sell_pressed() -> void:
	if not current_tower or not is_instance_valid(current_tower):
		return
	GameManager.add_money(int(current_tower.total_spent * 0.8))
	current_tower.queue_free()
	hide_info()

func _on_prev_focus_pressed() -> void:
	if not current_tower or not is_instance_valid(current_tower):
		return
	var new_mode = current_tower.focus_mode - 1
	if new_mode < 0:
		new_mode = 3
	current_tower.set_focus_mode(new_mode)
	focus_mode_label.text = current_tower.get_focus_mode_name()

func _on_next_focus_pressed() -> void:
	if not current_tower or not is_instance_valid(current_tower):
		return
	current_tower.set_focus_mode((current_tower.focus_mode + 1) % 4)
	focus_mode_label.text = current_tower.get_focus_mode_name()

func _input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide_info()
		get_viewport().set_input_as_handled()
