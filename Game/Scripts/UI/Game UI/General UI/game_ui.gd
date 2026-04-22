extends Control

var game_menu_scene = preload("res://Game/Scenes/UI/Game UI/Game Menu/game_menu.tscn")

@onready var speed_up_button = $Panel / SpeedUpButton
@onready var shop_toggle_button = $"../Bottom Info/Panel/ShopToggleButton"

enum ButtonState{START_WAVE, SPEED_UP}
var _button_state: = ButtonState.START_WAVE
var _next_wave_number: = 1
var is_sandbox: = false
var current_level_key: = ""
var _level_beaten: = false
var _was_fast_before_eave_end: = false
var _pending_congratulations: = false

var is_fast: bool = false
var is_fast_forward: bool = false
var is_super_fast_forward: bool = false

const DEBUG_MODE: = true

func _ready() -> void :
    GameManager.ui = self

    WaveManager.wave_completed.connect(_on_wave_completed)
    WaveManager.wave_started.connect(_on_wave_started)
    WaveManager.all_waves_completed.connect(_on_all_waves_completed)

    _set_button_state(ButtonState.START_WAVE)

    var debug_container = get_node_or_null("DebugOptinonsContainer")
    if debug_container:
        debug_container.visible = DEBUG_MODE

    if DEBUG_MODE:
        var victory_btn = get_node_or_null("DebugOptinonsContainer/VictoryButton")
        if victory_btn:
            victory_btn.pressed.connect(_trigger_victory)

        var lose_btn = get_node_or_null("DebugOptinonsContainer/LoseButton")
        if lose_btn:
            lose_btn.pressed.connect(_on_lose_button_pressed)

        var unlock_level_btn = get_node_or_null("DebugOptinonsContainer/UnlockNextLevelButton")
        if unlock_level_btn:
            unlock_level_btn.pressed.connect( func():
                ProgressManager.unlock_next_level_after(current_level_key))

        var lock_level_btn = get_node_or_null("DebugOptinonsContainer/LockPrevLevelButton")
        if lock_level_btn:
            lock_level_btn.pressed.connect( func():
                var idx = ProgressManager.LEVEL_ORDER.find(current_level_key)
                if idx > 0:
                    ProgressManager.unlocked_levels.erase(ProgressManager.LEVEL_ORDER[idx - 1])
                    ProgressManager.save_progress())

        var unlock_enemy_btn = get_node_or_null("DebugOptinonsContainer/UnlockNextEnemyButton")
        if unlock_enemy_btn:
            unlock_enemy_btn.pressed.connect( func():
                var max_id = ProgressManager.unlocked_enemies.max() if not ProgressManager.unlocked_enemies.is_empty() else 0
                var next_id = max_id + 1
                if next_id not in ProgressManager.unlocked_enemies:
                    ProgressManager.unlocked_enemies.append(next_id)
                    ProgressManager.save_progress())

        var lock_enemy_btn = get_node_or_null("DebugOptinonsContainer/LockPrevEnemyButton")
        if lock_enemy_btn:
            lock_enemy_btn.pressed.connect( func():
                if not ProgressManager.unlocked_enemies.is_empty():
                    ProgressManager.unlocked_enemies.erase(ProgressManager.unlocked_enemies.max())
                    ProgressManager.save_progress())

        var start_wave_btn = get_node_or_null("DebugOptinonsContainer/WaveContainer/StartWaveButton")
        if start_wave_btn:
            start_wave_btn.pressed.connect(_on_start_wave_button_pressed)

    if speed_up_button:
        speed_up_button.pressed.connect(_on_speed_up_button_pressed)

    if shop_toggle_button:
        shop_toggle_button.visible = false
        shop_toggle_button.pressed.connect(_on_shop_toggle_button_pressed)

func _set_button_state(state: ButtonState) -> void :
    _button_state = state
    match state:
        ButtonState.START_WAVE:
            speed_up_button.text = "Start Wave " + str(_next_wave_number)
            speed_up_button.disabled = false
        ButtonState.SPEED_UP:
            speed_up_button.text = "Normal Speed" if GameManager.is_fast else "Speed Up"
            speed_up_button.disabled = false

func _on_speed_up_button_pressed() -> void :
    if is_sandbox:
        GameManager.speed_up()
        _set_button_state(ButtonState.SPEED_UP)
        return
    match _button_state:
        ButtonState.START_WAVE:
            _set_button_state(ButtonState.SPEED_UP)
            WaveManager.start_wave(_next_wave_number)
            if _was_fast_before_eave_end:
                _was_fast_before_eave_end = false
                GameManager.set_speed(true)
        ButtonState.SPEED_UP:
            GameManager.speed_up()
            _set_button_state(ButtonState.SPEED_UP)

func _on_wave_started(_wave_num: int) -> void :
    _button_state = ButtonState.SPEED_UP
    speed_up_button.text = "Normal Speed" if GameManager.is_fast else "Speed Up"
    speed_up_button.disabled = false

func _on_wave_completed(wave_num: int) -> void :
    if not is_sandbox and wave_num >= WaveManager.get_level_max_wave():
        _trigger_victory()
        SoundManager.play_constant("Victory_better")

    if is_sandbox:
        speed_up_button.text = "Speed Up" if not GameManager.is_fast else "Normal Speed"
        speed_up_button.disabled = false
        _button_state = ButtonState.SPEED_UP
        return

    _next_wave_number = wave_num + 1

    if _next_wave_number <= WaveManager.get_total_waves():
        if WaveManager.is_auto_start:
            speed_up_button.text = "Normal Speed" if GameManager.is_fast else "Speed Up"
            speed_up_button.disabled = false
            _button_state = ButtonState.SPEED_UP
        else:
            if GameManager.is_fast:
                GameManager.set_speed(false)
            _set_button_state(ButtonState.START_WAVE)
    else:
        if GameManager.is_fast and not WaveManager.is_auto_start:
            _was_fast_before_eave_end = false
            GameManager.set_speed(false)

func _trigger_victory() -> void :
    if _level_beaten:
        return
    _level_beaten = true
    if current_level_key != "":
        ProgressManager.unlock_next_level_after(current_level_key)
        ProgressManager.mark_level_beaten(current_level_key)
        if current_level_key == "level_5":
            _pending_congratulations = true
            GameManager.show_congratulations_on_menu = true
    var canvas = CanvasLayer.new()
    canvas.layer = 20
    get_tree().root.add_child(canvas)
    var victory_scene = load("res://Game/Scenes/UI/Game UI/Victory/Victory.tscn")
    if victory_scene:
        canvas.add_child(victory_scene.instantiate())
    get_tree().paused = true

func _show_congratulations() -> void :
    var canvas = CanvasLayer.new()
    canvas.layer = 20
    get_tree().root.add_child(canvas)
    var congrats = load("res://Game/Scenes/UI/Game UI/Congratulations/congratulations.tscn")
    if congrats:
        SoundManager.play_constant("Victory_better")
        canvas.add_child(congrats.instantiate())
    get_tree().paused = true

func _on_all_waves_completed() -> void :
    speed_up_button.text = "Victory!"
    speed_up_button.disabled = true

func _on_start_wave_button_pressed() -> void :
    WaveManager.start_wave(_next_wave_number)

func _on_lose_button_pressed() -> void :
    GameManager.lose_game()

func _on_settings_button_pressed() -> void :
    var menu = game_menu_scene.instantiate()
    add_child(menu)
    get_tree().paused = true

func set_sandbox_mode() -> void :
    is_sandbox = true
    speed_up_button.text = "Speed Up"
    speed_up_button.disabled = false
    _button_state = ButtonState.SPEED_UP
    if shop_toggle_button:
        shop_toggle_button.visible = true

func _on_shop_toggle_button_pressed() -> void :
    var layout = get_parent()
    if layout and layout.has_method("toggle_shop"):
        layout.toggle_shop()

func set_start_wave(wave_num: int) -> void :
    _next_wave_number = wave_num
    _set_button_state(ButtonState.START_WAVE)

func on_game_restarted() -> void :

    _level_beaten = false
    _was_fast_before_eave_end = false
    if is_sandbox:
        speed_up_button.text = "Speed Up"
        _button_state = ButtonState.SPEED_UP
    else:
        _next_wave_number = 1
        _set_button_state(ButtonState.START_WAVE)




func _input(event: InputEvent) -> void :
    if event.is_action_pressed("fast_forward_3x"):
        is_fast = !is_fast
        if is_fast: 
            is_fast_forward = false
            is_super_fast_forward = false
        _update_speed()
        _on_speed_up_button_pressed()

    if event.is_action_pressed("fast_forward_6x"):
        if get_tree().current_scene.name == "Game Layout":
            is_fast_forward = !is_fast_forward
            if is_fast_forward: 
                is_fast = false
                is_super_fast_forward = false
        _update_speed()
    
    #robi jakiegoś dziwnego bugga dodać potem ( bardzo dziwnego )
    
    #if event.is_action_pressed("fast_forward_12x"):
    #   if get_tree().current_scene.name == "Game Layout":
    #      is_super_fast_forward = !is_super_fast_forward
    #      if is_super_fast_forward: 
    #          is_fast = false
    #         is_fast_forward = false
    # _update_speed()

func _update_speed() -> void :
    if is_super_fast_forward:
        Engine.time_scale = 12.0
    elif is_fast_forward:
        Engine.time_scale = 6.0
    elif is_fast:
        Engine.time_scale = 3.0
    else:
        Engine.time_scale = 1.0
