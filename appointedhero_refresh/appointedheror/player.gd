extends Entity

@export var player_weapon: PackedScene
@onready var neck = $SpringArm3D/PivotPoint
@onready var camera = $SpringArm3D/PivotPoint/Camera3D
@onready var barbie = $Barbarian
@onready var springy = $SpringArm3D
@onready var dodgey = $DodgeTimer
var is_attacking = false

const SPEED = 7.0
const JUMP_VELOCITY = 4.5
const DODGE_TIME = 0.55
const FWD_DODGE_DIS = 10
const BWK_DODGE_DIS = -5
const LOOK_SENS = 2.5
const LIGHT_ATK_LUNG = 10
const HEAVY_ATK_LUNG = 15
const ANGLE_CONVERSION = 75

func _ready() -> void:
	#TESTCODE: Allows my player to stay alive longer
	upgrade_health(1000.0)
	print(" spawned with health: ", current_health)
	#END
	if player_weapon:
		equip_weapon(player_weapon)

func _physics_process(delta: float) -> void:
	
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
		perform_attack("player_Melee_1H_Attack_Stab")
		velocity = barbie.global_transform.basis.z * HEAVY_ATK_LUNG
	# Light Attack
	if Input.is_action_just_pressed("light_attack") and is_on_floor():
		perform_attack("player_Melee_1H_Attack_Slice_Diagonal")
		velocity = barbie.global_transform.basis.z * LIGHT_ATK_LUNG
		
	_looking_process(delta)
	_moving_process(delta)
	move_and_slide()

func _looking_process(delta) -> void:
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	if look_dir.length() > 0:
		# 2. HORIZONTAL: Rotate the entire rig around the player
		# We rotate the SpringArm itself so the camera orbits the character
		springy.rotate_y(-look_dir.x * LOOK_SENS * delta)
		
		# 3. VERTICAL: Rotate only the neck/pivot point
		neck.rotate_x(-look_dir.y * LOOK_SENS * delta)
		
		# 4. CLAMP: Keep the camera from flipping upside down
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		# 5. FIX TILT: Joysticks can sometimes cause "Z-roll" (leaning)
		# This keeps the horizon perfectly level
		springy.rotation.z = 0
		neck.rotation.z = 0

func _moving_process(delta) -> void:
	
	if anim_state:
		var current_node = anim_state.get_current_node()
		is_attacking = current_node.contains("Attack")
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Calculate direction based on the SPRING ARM'S orientation, not the player's
	var direction : Vector3 = (springy.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0 # Keep us from flying into the air if the camera is tilted

	if is_attacking and is_on_floor():
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
		barbie.rotation.y = lerp_angle(barbie.rotation.y, target_angle, delta * 10.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	update_animations(direction)

func execute_dodge():
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Calculate world direction relative to camera
	var look_basis = springy.global_transform.basis
	var dodge_dir = (look_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	dodge_dir.y = 0

	if dodge_dir.length() > 0.1:
		# Snap the Barbarian's mesh
		var target_angle = atan2(-dodge_dir.x, -dodge_dir.z) + deg_to_rad(ANGLE_CONVERSION)
		barbie.rotation.y = target_angle
		
		# Play the forward roll animation
		anim_state.travel("player_Dodge_Forward")
		velocity = dodge_dir * FWD_DODGE_DIS
	else:
		# Backstep
		anim_state.travel("player_Dodge_Backward")
		velocity = barbie.global_transform.basis.z * BWK_DODGE_DIS
