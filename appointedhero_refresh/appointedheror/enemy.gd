extends Entity

enum State {WANDER, CHASE, DEAD}
var current_state = State.WANDER
@export var enemy_weapon: PackedScene

@export var attack_range: float = 2.0
@export var stop_distance: float = 1.5 
@export var wander_radius: float = 5.0
@export var chase_speed: float = 3.0
@export var wander_speed: float = 1.7
var target_position: Vector3
var player: CharacterBody3D = null

func _ready():
	target_position = global_position
	if enemy_weapon:
		equip_weapon(enemy_weapon)

	$WanderTimer.wait_time = randf_range(2.0, 5.0)
	$WanderTimer.start()

func _physics_process(_delta):
	if current_health <= 0:
		current_state = State.DEAD
		
	check_weapon_hitbox()	
	var current_dir = velocity
	current_dir.y = 0
	
	if current_dir.length() > 0.1:
		current_dir = current_dir.normalized()
	else:
		current_dir = Vector3.ZERO
	update_animations(current_dir)
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * _delta
	match current_state:
		State.WANDER:
			_wander_logic(_delta)
		State.CHASE:
			_chase_logic(_delta)
		State.DEAD:
			velocity = Vector3 (0,0,0)
			return

func _wander_logic(delta):
	is_attacking = false
	# Calculate distance to target and follow and look at it
	var dist = global_position.distance_to(target_position)
	if dist > 0.5:
		var direction = global_position.direction_to(target_position)
		velocity.x = direction.x * wander_speed
		velocity.z = direction.z * wander_speed
		look_at(Vector3(target_position.x, global_position.y, target_position.z), Vector3.UP)
	else:
		velocity = Vector3.ZERO # Stop moving when arrived
		
	move_and_slide()

func _chase_logic(delta):
	if player:
		var dist = global_position.distance_to(player.global_position)
		
		# Move only if we are outside the attack range
		if dist > stop_distance:
			var direction = global_position.direction_to(player.global_position)
			velocity.x = direction.x * chase_speed
			velocity.z = direction.z * chase_speed
			is_attacking = false
		else:
			is_attacking = true
			velocity.x = 0
			velocity.z = 0
		
		# Always look at the player when chasing/attacking
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		
		move_and_slide()
		
		# Attack if within range
		if dist <= attack_range:
			perform_attack("player_Melee_1H_Attack_Slice_Diagonal_Light")

func _on_agro_range_body_entered(body):
	
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE
		
func _on_wander_timer_timeout():
	var random_x = randf_range(-wander_radius, wander_radius)
	var random_z = randf_range(-wander_radius, wander_radius)
	target_position = global_position + Vector3(random_x, 0, random_z)
	
func _on_agro_range_body_exited(body):
	if body == player:
		player = null
		current_state = State.WANDER
		# Reset the wander timer so they don't just stand still
		$WanderTimer.start(randf_range(1.0, 3.0))
