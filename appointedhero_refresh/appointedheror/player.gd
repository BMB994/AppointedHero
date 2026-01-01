extends Entity

signal inventory_changed(rucksack: Array[ItemData], equipment: Dictionary)

@onready var neck = $SpringArm3D/PivotPoint
@onready var camera = $SpringArm3D/PivotPoint/Camera3D
@onready var slected_char = $Rogue
@onready var right_hand = $Rogue/Rig_Medium/Skeleton3D/RightHand/RightHandWeapon
@onready var left_hand = $Rogue/Rig_Medium/Skeleton3D/LeftHand/LeftHandWeapon
@onready var springy = $SpringArm3D
@onready var dodgey = $DodgeTimer
@onready var weapon_timey = $DodgeTimer
@onready var searchy = $LockOnArea
@onready var searchy_shape = $LockOnArea/CollisionShape3D
@onready var inventory_ui = $InventoryUI

@export var katana_test: ItemData
@export var club_test: ItemData

var target_enemy: Entity = null
var equipped_right: Node3D = null
var equipped_left: Node3D = null
var ruck_sacked: Array[ItemData] = []
var equipment_slots = {
	"RIGHT_HAND": null,
	"LEFT_HAND": null
}

const SPEED = 7.0
const JUMP_VELOCITY = 8
const DODGE_TIME = 0.55
const FWD_DODGE_DIS = 10
const BWK_DODGE_DIS = -5
const LOOK_SENS = 2.5
const LIGHT_ATK_LUNG = 5
const HEAVY_ATK_LUNG = 7
const ANGLE_CONVERSION = 180
const LOCKED_H_OFFSET = 1.5
const OFFSET_SPEED = 4.0

func _ready() -> void:
	#TESTCODE:
	#upgrade_health(1000.0)
	add_item_to_ruck(katana_test)
	add_item_to_ruck(club_test)

	#equip_from_data(test_weapon_resource)
	#END
func equip_from_data(data: ItemData): # Process resource file and equip
	match data.type:
		ItemData.SlotType.ONE_HAND:
			_clear_slot("right")
			
			if equipped_left and equipped_left.has_meta("is_2h"):
				_clear_slot("left")
			equipment_slots.RIGHT_HAND = data
			equipped_right = _spawn_model(data, right_hand)
			current_weapon = equipped_right

		ItemData.SlotType.TWO_HAND:
			_clear_slot("right")
			_clear_slot("left")
			equipment_slots.RIGHT_HAND = data
			equipment_slots.LEFT_HAND = data
			equipped_right = _spawn_model(data, right_hand)
			equipped_right.set_meta("is_2h", true)
			current_weapon = equipped_right

		ItemData.SlotType.SHIELD:

			_clear_slot("left")
			equipment_slots.LEFT_HAND = data

			if equipped_right and equipped_right.has_meta("is_2h"):
				_clear_slot("right")
				current_weapon = null
				
			equipped_left = _spawn_model(data, left_hand)
func equip_from_inventory(index: int): # item picked from UI inventory and then equipped
	if index >= ruck_sacked.size(): return
	
	var new_data = ruck_sacked[index]
	
	# Determine target slot based on ItemData type
	var slot_key = "RIGHT_HAND" 
	if new_data.type == ItemData.SlotType.SHIELD:
		slot_key = "LEFT_HAND"
	# Add more logic here for HEAD, CHEST etc.
	
	# 1. Grab the item currently in that slot (if any)
	var old_data = equipment_slots[slot_key]
	
	# 2. Swap them in the data structures
	ruck_sacked.remove_at(index)
	equipment_slots[slot_key] = new_data
	
	# 3. If there was an old item, put it back in the rucksack
	if old_data:
		ruck_sacked.append(old_data)
	
	# 4. Update 3D Visuals
	equip_from_data(new_data)
	
	# 5. Sync UI
	inventory_changed.emit(ruck_sacked, equipment_slots)
func _clear_slot(side: String):
	if side == "right" and equipped_right:
		equipped_right.queue_free()
		equipped_right = null
	elif side == "left" and equipped_left:
		equipped_left.queue_free()
		equipped_left = null
func _spawn_model(data: ItemData, socket: Node3D) -> Node3D:
	if data.scene_to_spawn == null:
		print("Error: No scene assigned to this resource")
		return null
		
	var instance = data.scene_to_spawn.instantiate()
	
	if instance.has_method("apply_item_data"):
		instance.apply_item_data(data)	
		
	if instance is BaseWeapon:
		instance.owner_entity = self
		
	socket.add_child(instance)
	instance.transform = Transform3D.IDENTITY

	return instance
func _physics_process(delta: float) -> void:
	check_weapon_hitbox()
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_released("inventory"):
		toggle_inventory()

	if inventory_ui.visible:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return 
		

	_handle_combat_inputs(delta)
	_looking_process(delta)
	_moving_process(delta)
	move_and_slide()
func _handle_combat_inputs(delta: float):
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		anim_state.travel("player_Jump_Start")
		return

	if is_attacking or not dodgey.is_stopped():
		return

	if Input.is_action_just_pressed("dodge"):
		dodgey.start(DODGE_TIME)
		execute_dodge()
	elif Input.is_action_just_pressed("heavy_attack"):
		_start_attack("player_Melee_1H_Attack_Stab_Heavy", HEAVY_ATK_LUNG, delta)
	elif Input.is_action_just_pressed("light_attack"):
		_start_attack("player_Melee_1H_Attack_Slice_Diagonal_Light", LIGHT_ATK_LUNG, delta)
	elif Input.is_action_just_pressed("lock_on"):
		_lock_on()
func _start_attack(anim: String, lunge: float, delta: float):
	perform_attack(anim)
	if is_locked_on and target_enemy:
		rotate_towards_target(target_enemy.global_position, delta, true)
	velocity = slected_char.global_transform.basis.z * lunge
func _lock_on() -> void:
	if is_locked_on:
		is_locked_on = false
		target_enemy = null
		return

	var shape = searchy_shape.shape
	var max_range = 0.0
	
	if shape is SphereShape3D:
		max_range = shape.radius
	elif shape is CylinderShape3D:
		max_range = shape.radius
	elif shape is BoxShape3D:
		max_range = shape.size.x
	
	var potential_targets = searchy.get_overlapping_bodies()
	var closest_enemy = null
	var shortest_dist = max_range

	for body in potential_targets:
		if body.is_in_group("enemy") and body.current_health > 0:
			var dist = global_position.distance_to(body.global_position)
			if dist < shortest_dist:
				closest_enemy = body
				shortest_dist = dist

	if closest_enemy:
		print("Found enemy lock on")
		target_enemy = closest_enemy
		is_locked_on = true
func _looking_process(delta) -> void:
	if is_locked_on and target_enemy:
		# 1. Check if target is still valid (alive/in range)
		if target_enemy.current_health <= 0:
			is_locked_on = false
			target_enemy = null
			return

		var target_pos = target_enemy.global_position + Vector3(0, 1.3, 0)
		var new_transform = springy.global_transform.looking_at(target_pos, Vector3.UP)
		springy.global_transform.basis = springy.global_transform.basis.slerp(new_transform.basis, delta * OFFSET_SPEED)
		neck.rotation.x = lerp_angle(neck.rotation.x, 0, delta * OFFSET_SPEED)
		springy.rotation.z = 0
		
		# Move camera slightly offset
		camera.h_offset = lerp(camera.h_offset, LOCKED_H_OFFSET, delta * OFFSET_SPEED)
		
	else:
		var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		# Return the camera offset
		camera.h_offset = lerp(camera.h_offset, 0.0, delta * OFFSET_SPEED)
		if look_dir.length() > 0:
			springy.rotate_y(-look_dir.x * LOOK_SENS * delta)
			neck.rotate_x(-look_dir.y * LOOK_SENS * delta)
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(80))
			springy.rotation.z = 0
			neck.rotation.z = 0
func _moving_process(delta) -> void:
	if anim_state:
		var current_node = anim_state.get_current_node()
		is_attacking = current_node.contains("Attack")
		
	if not is_on_floor():
		velocity += get_gravity() * delta
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if inventory_ui.visible: # Dont allow char movement when in inventory
		return
		
	# Calculate direction based on the SPRING ARM'S orientation, not the player's
	var direction : Vector3 = (springy.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0 # Keep us from flying into the air if the camera is tilted
	
		
	if is_attacking and is_on_floor():
		if is_locked_on:
			rotate_towards_target(target_enemy.global_position, delta)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	elif not dodgey.is_stopped():
		velocity.x = move_toward(velocity.x, 0, 2.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 2.0 * delta)	
	elif direction:
		if is_on_floor():
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			# Moving at 50% speed in air
			velocity.x = move_toward(velocity.x, direction.x * SPEED, delta * SPEED * 2.0)
			velocity.z = move_toward(velocity.z, direction.z * SPEED, delta * SPEED * 2.0)
			
		var target_angle = atan2(-direction.x, -direction.z) + deg_to_rad(ANGLE_CONVERSION)
		slected_char.rotation.y = lerp_angle(slected_char.rotation.y, target_angle, delta * 10.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	update_animations(direction)
func rotate_towards_target(target_pos: Vector3, delta: float, instant: bool = false):
	var dir_to_target = (target_pos - global_position).normalized()
	var target_angle = atan2(-dir_to_target.x, -dir_to_target.z) + deg_to_rad(ANGLE_CONVERSION)
	
	if instant:
		slected_char.rotation.y = target_angle
	else:
		# 20.0 is a good 'tracking' speed for attacks
		slected_char.rotation.y = lerp_angle(slected_char.rotation.y, target_angle, delta * 20.0)
func execute_dodge():
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Calculate world direction relative to camera
	var look_basis = springy.global_transform.basis
	var dodge_dir = (look_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	dodge_dir.y = 0

	if dodge_dir.length() > 0.1:
		# Snap the Barbarian's mesh
		var target_angle = atan2(-dodge_dir.x, -dodge_dir.z) + deg_to_rad(ANGLE_CONVERSION)
		slected_char.rotation.y = target_angle
		
		# Play the forward roll animation
		anim_state.travel("player_Dodge_Forward")
		velocity = dodge_dir * FWD_DODGE_DIS
	else:
		# Backstep
		anim_state.travel("player_Dodge_Backward")
		velocity = slected_char.global_transform.basis.z * BWK_DODGE_DIS			
func toggle_inventory():
	inventory_ui.visible = !inventory_ui.visible
	
	if inventory_ui.visible:
		inventory_changed.emit(ruck_sacked, equipment_slots)
		inventory_ui.focus_first_slot() 
func add_item_to_ruck(data: ItemData):
	ruck_sacked.append(data)
	inventory_changed.emit(ruck_sacked, equipment_slots)
func unequip_item(slot_key: String):
	if not equipment_slots.has(slot_key) or equipment_slots[slot_key] == null:
		return
		
	var item_to_return = equipment_slots[slot_key]
	
	# 1. Remove from equipment data
	equipment_slots[slot_key] = null
	
	# 2. Clear 3D model
	if slot_key == "RIGHT_HAND":
		_clear_slot("right")
		current_weapon = null
	elif slot_key == "LEFT_HAND":
		_clear_slot("left")
	# TODO: Add other cases (HEAD, CHEST, etc) as needed
		
	# 3. Put back in rucksack
	add_item_to_ruck(item_to_return)
	
	# 4. Notify UI
	inventory_changed.emit(ruck_sacked, equipment_slots)
