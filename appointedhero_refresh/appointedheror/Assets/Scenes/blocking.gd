extends State

func enter():
	if player.equipped_left:
		player.anim_state.travel("Block_State")

func exit():
	if player.equipped_left and player.equipped_left.has_method("lower_shield"):
		player.equipped_left.lower_shield()

func physics_update(delta: float):
	if not Input.is_action_pressed("block"):
		state_machine.change_to("Idle")
		return
		
	# Attack
	if Input.is_action_just_pressed("light_attack") or Input.is_action_just_pressed("heavy_attack"):
		state_machine.change_to("Attack")
		return
		
	# Dodge
	if Input.is_action_just_pressed("dodge"):
		state_machine.change_to("Dodge")
		return
		
	# Jump
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_to("Jump")
		return	
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction : Vector3 = (player.springy.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0 

	player.velocity.x = direction.x * (player.SPEED * 0.5)
	player.velocity.z = direction.z * (player.SPEED * 0.5)
	
	if input_dir.length() > 0.2:
		player.anim_tree.set("parameters/Block_State/Blend2/blend_amount", 1.0)
		
	else:
		player.anim_tree.set("parameters/Block_State/Blend2/blend_amount", 0.0)
		
	var camera_forward = -player.springy.global_transform.basis.z
	var look_angle = atan2(-camera_forward.x, -camera_forward.z) + deg_to_rad(player.ANGLE_CONVERSION)
	
	player.slected_char.rotation.y = lerp_angle(player.slected_char.rotation.y, look_angle, delta * 10.0)
