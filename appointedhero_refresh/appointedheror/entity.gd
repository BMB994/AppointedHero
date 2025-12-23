extends CharacterBody3D
class_name Entity

# Animation section for things inherting entity class
@onready var anim_tree : AnimationTree = find_child("AnimationTree")
@onready var anim_state = anim_tree.get("parameters/playback") if anim_tree else null

var current_weapon = null
signal health_changed(new_health, max_health)
@export var max_health: float = 100.0
@onready var current_health: float = max_health

# --- NEW ANIMATION FUNCTION ---
func update_animations(direction: Vector3):
	if not anim_tree: return
	
	## NEW: Get the name of what is currently playing
	#var current_node = anim_state.get_current_node()
	#
	## If we are attacking, DO NOT update the idle/moving conditions.
	## This lets the attack finish without being interrupted.
	#if current_node.contains("Attack"):
		#return
	print("Speed: ", direction.length(), " | Moving: ", anim_tree.get("parameters/conditions/is_running"))
	if is_on_floor():
		var is_running = direction.length() > 0.1
		# These strings must match the "Conditions" we set in the Editor
		anim_tree.set("parameters/conditions/is_running", is_running)
		anim_tree.set("parameters/conditions/is_idle", not is_running)

# Modified to trigger the visual swing as well
func perform_attack(anim_name: String = "player_Melee_1H_Attack_Slice_Diagonal"):
	# 1. Trigger the Visual Animation
	if anim_state:
		anim_state.travel(anim_name)
	
	# 2. Trigger the Weapon Logic (Hitboxes, etc)
	if current_weapon and current_weapon.has_method("use"):
		current_weapon.use()
	else:
		print(name, " tried to attack but has no weapon or weapon has no 'use' function")
		
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
