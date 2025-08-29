extends Control
signal upgrade_health_button
signal upgrade_damage_button
signal upgrade_attack_speed
signal arrows
signal arrow_level
signal arrow_speed
signal lightning
signal lightning_upgrade
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


func _on_unlock_arrows_pressed() -> void:
	arrows.emit()


func _on_upgrade_arrows_pressed() -> void:
	arrow_level.emit()


func _on_increase_arrow_speed_pressed() -> void:
	arrow_speed.emit()


func _on_unlock_lightning_pressed() -> void:
	lightning.emit()


func _on_upgrade_lightning_pressed() -> void:
	lightning_upgrade.emit()


func _on_back_to_game_pressed() -> void:
	self.hide()
