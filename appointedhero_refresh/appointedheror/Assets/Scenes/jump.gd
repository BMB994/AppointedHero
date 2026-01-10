extends State

func enter():
	player.velocity.y = player.JUMP_VELOCITY
	player.anim_state.travel("player_Jump_Start")

func physics_update(delta: float):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (player.springy.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	player.velocity.x = direction.x * (player.SPEED * 0.5)
	player.velocity.z = direction.z * (player.SPEED * 0.5)
	
	var target_angle = atan2(-direction.x, -direction.z) + deg_to_rad(player.ANGLE_CONVERSION)
	player.slected_char.rotation.y = lerp_angle(player.slected_char.rotation.y, target_angle, delta * 10.0)

	if player.is_on_floor() and player.velocity.y <= 0:
		if input_dir.length() > 0.1:
			state_machine.change_to("Move")
		else:
			state_machine.change_to("Idle")
