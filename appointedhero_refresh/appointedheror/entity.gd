extends CharacterBody3D
class_name Entity

var current_weapon = null
# This tells the game "I have news about health!"
signal health_changed(new_health, max_health)
@export var max_health: float = 100.0
@onready var current_health: float = max_health

func equip_weapon(weapon_scene: PackedScene):
	# find_child searches the whole scene tree of this entity for "RightHand"
	var hand_node = find_child("RightHandWeapon")
	
	if hand_node == null:
		print("Warning: ", name, " has no node named 'RightHandWeapon'. Check your scene!")
		return

	if current_weapon:
		current_weapon.queue_free()
	
	current_weapon = weapon_scene.instantiate()
	hand_node.add_child(current_weapon)
	
	# Reset transform so it snaps to the hand
	current_weapon.transform = Transform3D.IDENTITY

func perform_attack():
	if current_weapon and current_weapon.has_method("use"):
		current_weapon.use()
	else:
		print(name, " tried to attack but has no weapon or weapon has no 'use' function")

func upgrade_health(amount: float):
	max_health = max_health + amount
	heal(max_health - current_health)

func heal(amount: float):
	current_health = current_health + amount
	health_changed.emit(current_health, max_health)
	
func take_damage(amount: float):
	current_health -= amount
	print(name, " took damage! Remaining: ", current_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	# For now, just remove them. Later, you can add death animations or loot!
	print(name, " has died.")
	queue_free()
