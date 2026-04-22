extends Panel

@export var tower_scene: PackedScene
@export var tower_name: String = "Tower"
@export var tower_cost: int = 100
@export var tower_icon: Texture2D

@onready var cost_label = $VBoxContainer / CostLabel
@onready var name_label = $VBoxContainer / NameLabel
@onready var icon_rect = $VBoxContainer / TextureRect

var can_afford: = true
var _is_locked: = false
var _owns_preview: = false
var is_dragging: = false
var drag_distance: = 0.0
const DRAG_THRESHOLD: = 5

func _ready():
    name_label.text = tower_name
    cost_label.text = "$" + str(tower_cost)
    icon_rect.texture = tower_icon
    GameManager.money_changed.connect(_on_money_changed)
    PlacementManager.placement_cancelled.connect(_on_preview_ended)
    PlacementManager.placement_confirmed.connect(_on_preview_ended)

    if tower_scene:
        var temp = tower_scene.instantiate()
        var tid = temp.get("tower_id")
        temp.queue_free()
        if tid != null:
            _is_locked = tid not in ProgressManager.unlocked_towers
    update_affordability()

func _on_money_changed(_new_amount: int) -> void :
    update_affordability()

func update_affordability():
    if _is_locked:
        can_afford = false
        modulate = Color(0.3, 0.3, 0.3, 0.7)
        return
    can_afford = GameManager.money >= tower_cost
    modulate = Color.WHITE if can_afford else Color(0.5, 0.5, 0.5, 0.7)

func _on_preview_ended():
    _owns_preview = false
    is_dragging = false
    drag_distance = 0.0

func _gui_input(event: InputEvent):
    if SettingsManager.placement_mode == SettingsManager.PlacementMode.CLICK_AND_DROP:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            if can_afford and not _owns_preview:
                _start()
                get_viewport().set_input_as_handled()
    else:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed and can_afford and not _owns_preview:
                is_dragging = true
                drag_distance = 0.0
            elif not event.pressed and is_dragging:
                is_dragging = false
                if _owns_preview:
                    PlacementManager.attempt_place()

        if event is InputEventMouseMotion and is_dragging and not _owns_preview:
            drag_distance += event.relative.length()
            if drag_distance > DRAG_THRESHOLD:
                _start()

func _input(event: InputEvent):
    if not _owns_preview:
        return

    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        PlacementManager.cancel()
        get_viewport().set_input_as_handled()
        return

    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        PlacementManager.cancel()
        get_viewport().set_input_as_handled()
        return

    if SettingsManager.placement_mode == SettingsManager.PlacementMode.CLICK_AND_DROP:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            PlacementManager.attempt_place()
            get_viewport().set_input_as_handled()
    else:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            is_dragging = false
            PlacementManager.attempt_place()
            get_viewport().set_input_as_handled()

func _start():
    if not tower_scene or not can_afford:
        return
    PlacementManager.start_preview(tower_scene, tower_cost)
    _owns_preview = true
    is_dragging = true
