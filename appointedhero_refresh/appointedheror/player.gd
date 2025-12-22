extends Entity

@export var player_weapon: PackedScene
@onready var neck = $NeckPivotPoint  # Reference to the pivot node
@onready var camera = $NeckPivotPoint/Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LOOK_SENS = 2.5

func _ready() -> void:
	#TESTCODE: Allows my player to stay alive longer
	upgrade_health(1000.0)
	if player_weapon:
		equip_weapon(player_weapon)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("use"):# Define "attack" in Input Map (e.g., Left Click)
		perform_attack()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	# Rotate the whole player body left/right
	rotate_y(-look_dir.x * LOOK_SENS * delta)
	# Rotate ONLY the neck up/down
	neck.rotate_x(-look_dir.y * LOOK_SENS * delta)
	neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	move_and_slide()
