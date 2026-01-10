extends State

var dodge_timer: float = 0.0

func enter():
	dodge_timer = player.DODGE_TIME
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var look_basis = player.springy.global_transform.basis
	var dodge_dir = (look_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	dodge_dir.y = 0

	if dodge_dir.length() > 0.1:
		# Roll Forward/Directional
		player.slected_char.rotation.y = atan2(-dodge_dir.x, -dodge_dir.z) + deg_to_rad(player.ANGLE_CONVERSION)
		player.anim_state.travel("player_Dodge_Forward")
		player.velocity = dodge_dir * player.FWD_DODGE_DIS
	else:
		# Backstep
		player.anim_state.travel("player_Dodge_Backward")
		player.velocity = player.slected_char.global_transform.basis.z * player.BWK_DODGE_DIS

func physics_update(delta: float):
	dodge_timer -= delta
	
	# Slow down dodge momentum
	player.velocity.x = move_toward(player.velocity.x, 0, 1.0)
	player.velocity.z = move_toward(player.velocity.z, 0, 1.0)
	
	if dodge_timer <= 0:
		state_machine.change_to("Idle")
