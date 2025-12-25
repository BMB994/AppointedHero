extends Entity

@onready var neck = $SpringArm3D/PivotPoint
@onready var camera = $SpringArm3D/PivotPoint/Camera3D
@onready var slected_char = $Barbarian
@onready var right_hand = $Barbarian/Rig_Medium/Skeleton3D/RightHand/RightHandWeapon
@onready var starting_weapon = $samurai_sword
@onready var springy = $SpringArm3D
@onready var dodgey = $DodgeTimer
@onready var weapon_timey = $DodgeTimer
@onready var searchy = $LockOnArea
@onready var searchy_shape = $LockOnArea/CollisionShape3D

var target_enemy: Entity = null

const SPEED = 7.0
const JUMP_VELOCITY = 4.5
const DODGE_TIME = 0.55
const FWD_DODGE_DIS = 10
const BWK_DODGE_DIS = -5
const LOOK_SENS = 2.5
const LIGHT_ATK_LUNG = 5
const HEAVY_ATK_LUNG = 7
const ANGLE_CONVERSION = 75
const LOCKED_H_OFFSET = 1.5
const OFFSET_SPEED = 4.0

func _ready() -> void:
	#TESTCODE: Allows my player to stay alive longer
	upgrade_health(1000.0)
	#END
	if starting_weapon and right_hand:
		# 1. Move the node to the hand slot
		starting_weapon.reparent(right_hand)
		# 2. Reset transforms so it snaps to (0,0,0) of the hand
		starting_weapon.position = Vector3.ZERO
		starting_weapon.rotation = Vector3.ZERO
		# 3. Assign it to current_weapon so Entity.gd knows it exists
		current_weapon = starting_weapon
		current_weapon.owner_entity = self
		print("Sword successfully snapped to hand!")
	#equip_weapon(starting_weapon)

func _physics_process(delta: float) -> void:
	check_weapon_hitbox()
	
	# Dodge
	if Input.is_action_just_pressed("dodge") and is_on_floor() and not is_attacking and dodgey.is_stopped():
		dodgey.start(DODGE_TIME)
		execute_dodge()
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_state.travel("player_Jump_Start")
	# Heavy Attack	
	if Input.is_action_just_pressed("heavy_attack") and is_on_floor():
		perform_attack("player_Melee_1H_Attack_Stab_Heavy")
		if is_locked_on and target_enemy:
			rotate_towards_target(target_enemy.global_position, delta, true)
		velocity = slected_char.global_transform.basis.z * HEAVY_ATK_LUNG
	# Light Attack
	if Input.is_action_just_pressed("light_attack") and is_on_floor():
		perform_attack("player_Melee_1H_Attack_Slice_Diagonal_Light")
		if is_locked_on and target_enemy:
			rotate_towards_target(target_enemy.global_position, delta, true)
		velocity = slected_char.global_transform.basis.z * LIGHT_ATK_LUNG
	# Lock On
	if Input.is_action_just_pressed("lock_on") and is_on_floor():
		_lock_on()
		
	_looking_process(delta)
	_moving_process(delta)
	move_and_slide()
	
func _lock_on() -> void:
	
	# Find all enemies within radius
	# Sort them off distance
	# Pick closest one
	# If locked on is true and we get here, turn it off and clear list
	if is_locked_on:
		is_locked_on = false
		target_enemy = null
		return

	# Get the radius from the collision shape to use as our limit
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
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

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
