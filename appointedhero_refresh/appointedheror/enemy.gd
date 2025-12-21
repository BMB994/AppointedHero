extends Entity

enum State {WANDER, CHASE, ATTACK}
var current_state = State.WANDER

@export var wander_radius: float = 5.0
@export var chase_speed: float = 3.0
@export var wander_speed: float = 1.7
var target_position: Vector3
var player: CharacterBody3D = null

func _ready():
	target_position = global_position
	$WanderTimer.timeout.connect(_on_wander_timer_timeout)
	$WanderTimer.wait_time = randf_range(2.0, 5.0) # Each enemy waits a different amount
	$WanderTimer.start()

func _physics_process(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	match current_state:
		State.WANDER:
			_wander_logic(delta)
		State.CHASE:
			_chase_logic(delta)

func _wander_logic(delta):
	# Calculate distance to target
	var dist = global_position.distance_to(target_position)
	
	# Only move if we aren't "there" yet
	if dist > 0.5:
		var direction = global_position.direction_to(target_position)
		velocity.x = direction.x * wander_speed
		velocity.z = direction.z * wander_speed
		# Optional: Make the enemy face where they are walking
		look_at(Vector3(target_position.x, global_position.y, target_position.z), Vector3.UP)
	else:
		velocity = Vector3.ZERO # Stop moving when arrived
		#$WanderTimer.stop()
		#$WanderTimer.wait_time = randf_range(2.0, 5.0) # Each enemy waits a different amount
		#$WanderTimer.start()
		
	move_and_slide()

func _chase_logic(delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity.x = direction.x * chase_speed
		velocity.z = direction.z * chase_speed
		move_and_slide()
		
		# If close enough, try to use weapon
		if global_position.distance_to(player.global_position) < 2.0:
			perform_attack()

func _on_agro_range_body_entered(body):
	if body.is_in_group("player"): # Make sure your Player is in a group called "player"
		player = body
		current_state = State.CHASE

func _on_wander_timer_timeout():
	var random_x = randf_range(-wander_radius, wander_radius)
	var random_z = randf_range(-wander_radius, wander_radius)
	# We set Y to the enemy's CURRENT Y position so they don't 
	# try to "fly" or "dig" toward the target.
	target_position = global_position + Vector3(random_x, 0, random_z)
func _on_agro_range_body_exited(body):
	if body == player:
		player = null
		current_state = State.WANDER
		# Reset the wander timer so they don't just stand still
		$WanderTimer.start(randf_range(1.0, 3.0))
