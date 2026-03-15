extends CanvasLayer

@onready var money_label = $MoneyLabel
@onready var health_label = $HealthLabel  # Add a new Label node

func _ready():
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.game_over.connect(_on_game_over)
	
	update_money_display(GameManager.money)
	update_health_display(GameManager.health)

func _on_money_changed(new_amount):
	update_money_display(new_amount)

func _on_health_changed(new_amount):
	update_health_display(new_amount)

func update_money_display(amount):
	money_label.text = "Money: $" + str(amount)

func update_health_display(amount):
	health_label.text = "Health: " + str(amount)

func _on_game_over():
	print("Game Over!")
	# Show game over screen, restart button, etc.
