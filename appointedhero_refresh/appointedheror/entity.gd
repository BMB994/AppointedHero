extends CharacterBody3D
class_name Entity

# Animation section for things inherting entity class
@onready var anim_tree : AnimationTree = find_child("AnimationTree")
@onready var anim_state = anim_tree.get("parameters/playback") if anim_tree else null

var current_weapon = null
var dead = false
signal health_changed(new_health, max_health)
@export var max_health: float = 100.0
@onready var current_health: float = max_health
var is_locked_on = false
var is_attacking = false
@onready var hitbox_delay = $HBoxDelay

	
func update_animations(direction: Vector3):
	if not anim_tree: return
	
	var grounded = is_on_floor()
	var moving = direction.length() > 0.1
	
	# Update ALL conditions based on the current frame's physics
	anim_tree.set("parameters/conditions/is_falling", not grounded and not dead)
	anim_tree.set("parameters/conditions/is_done_falling", grounded and not dead)
	anim_tree.set("parameters/conditions/is_running", grounded and moving and not dead)
	anim_tree.set("parameters/conditions/is_idle", grounded and not moving and not dead)
	anim_tree.set("parameters/conditions/is_dead", dead)
		
func perform_attack(anim_name: String = "start"):
	hitbox_delay.start()
	if dead:
		return

	if anim_state:
		anim_state.travel(anim_name)
	
	if current_weapon and current_weapon.has_method("use"):
		if anim_name.contains("Light"):
			current_weapon.use("light")
		elif anim_name.contains("Heavy"):
			current_weapon.use("heavy")
		else:
			current_weapon.use()
	else:
		print(name, " tried to attack but has no weapon or weapon has no 'use' function")
		
func equip_weapon(weapon_scene: PackedScene):
	var hand_node = find_child("RightHandWeapon")
	
	if hand_node == null:
		print("Warning: ", name, " has no node named 'RightHandWeapon'. Check your scene!")
		return

	if current_weapon:
		current_weapon.queue_free()
	
	current_weapon = weapon_scene.instantiate()
	current_weapon.owner_entity = self
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

func check_weapon_hitbox():
	if is_attacking and current_weapon:
		if hitbox_delay.is_stopped():
			current_weapon.enable_hitbox()

	elif current_weapon:
		current_weapon.disable_hitbox()
		
func die():
	dead = true
	print(name, " has died.")
	await get_tree().create_timer(2.0).timeout
	queue_free()
