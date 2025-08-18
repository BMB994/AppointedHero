extends Control
signal upgrade_health_button
signal upgrade_damage_button
signal upgrade_attack_speed
signal new_game
signal exit

func _ready() -> void:
	pass
	

func _on_increase_health_button_pressed() -> void:
	upgrade_health_button.emit()


func _on_new_game_pressed() -> void:
	new_game.emit()


func _on_increase_attack_speed_pressed() -> void:
	upgrade_attack_speed.emit()


func _on_exit_pressed() -> void:
	exit.emit()


func _on_increase_damage_pressed() -> void:
	upgrade_damage_button.emit()
