extends CharacterBody3D # Must match the node type!
class_name Entity

# In Entity.gd
@onready var hand = $RightHand # Path to your Hand Node3D
var current_weapon = null

func equip_weapon(weapon_scene: PackedScene):
	# 1. Clear the hand if something is already there
	if current_weapon:
		current_weapon.queue_free()
	
	# 2. Instance the new weapon
	current_weapon = weapon_scene.instantiate()
	
	# 3. Add it as a child of the hand
	hand.add_child(current_weapon)
	
	# 4. Reset its transform so it sits at (0,0,0) relative to the hand
	current_weapon.transform = Transform3D.IDENTITY

func perform_attack():
	if current_weapon and current_weapon.has_method("use"):
		current_weapon.use()
