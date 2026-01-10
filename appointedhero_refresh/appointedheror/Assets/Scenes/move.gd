extends State

func enter():
	player.anim_state.travel("player_Running_A")
func physics_update(delta: float):

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir.length() < 0.2:
		state_machine.change_to("Idle")
		return

	if Input.is_action_just_pressed("dodge"):
		state_machine.change_to("Dodge")
		return
	if Input.is_action_just_pressed("light_attack") or Input.is_action_just_pressed("heavy_attack"):
		state_machine.change_to("Attack")
		return
		
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_to("Jump")
		return
		
	if Input.is_action_just_pressed("block") and player.is_on_floor():
		state_machine.change_to("Blocking")
		return

	var direction : Vector3 = (player.springy.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0 

	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	

	var target_angle = atan2(-direction.x, -direction.z) + deg_to_rad(player.ANGLE_CONVERSION)
	player.slected_char.rotation.y = lerp_angle(player.slected_char.rotation.y, target_angle, delta * 10.0)
	
