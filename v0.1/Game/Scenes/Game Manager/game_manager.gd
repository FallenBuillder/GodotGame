extends Node

var money: int = 100
var health: int = 100  # Starting health

signal money_changed(new_amount)
signal health_changed(new_amount)
signal game_over

func add_money(amount: int):
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func take_damage(amount: int):
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		health = 0
		game_over.emit()
