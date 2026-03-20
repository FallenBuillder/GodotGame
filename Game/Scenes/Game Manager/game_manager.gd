extends Node

var money: int = 100
var health: int = 100  # Starting health
var wave: int = 0

signal money_changed(new_amount)
signal health_changed(new_amount)
signal wave_changed(new_amount)

signal game_over
signal restart 

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

func change_wave(amount: int):
	wave += amount
	wave_changed.emit(wave)
	if wave >= 10:
		wave = 0

func restart_game():
	restart.emit()
