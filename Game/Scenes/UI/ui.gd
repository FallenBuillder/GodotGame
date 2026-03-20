extends CanvasLayer

@onready var money_label = $MoneyLabel
@onready var health_label = $HealthLabel  # Add a new Label node
@onready var wave_label = $WaveLabel
var game_over_scene = preload("res://Game/Scenes/UI/game_over_screen.tscn")

func _ready():
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	
	GameManager.game_over.connect(_on_game_over)
	GameManager.restart.connect(_on_restart)
	
	update_money_display(GameManager.money)
	update_health_display(GameManager.health)
	update_wave_display(GameManager.wave)
	
	
func _on_money_changed(new_amount):
	update_money_display(new_amount)

func _on_health_changed(new_amount):
	update_health_display(new_amount)

func _on_wave_changed(new_amount):
	update_wave_display(new_amount)


func update_money_display(amount):
	money_label.text = "Money: $" + str(amount)

func update_health_display(amount):
	health_label.text = "Health: " + str(amount)

func update_wave_display(amount):
	wave_label.text = "Wave: " + str(amount)

func _on_game_over():
	print("Game Over!")
	var layer = CanvasLayer.new()
	add_child(layer)
	var screen_instance = game_over_scene.instantiate()
	layer.add_child(screen_instance)
	get_tree().paused = true

func _on_restart():
	print("test")	
	#delete enemies , towers from arrays
	#call a function to delete all current waves
	#set health , money to 0
	
	
