extends State

func enter():
	player.anim_state.travel("player_Idle_B")

func physics_update(_delta: float):

	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	player.velocity.z = move_toward(player.velocity.z, 0, player.SPEED)

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.length() >= 0.2:
		state_machine.change_to("Move")
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
	
	# Block
	if Input.is_action_just_pressed("block") and player.is_on_floor():
		state_machine.change_to("Blocking")
		return
		
	if player.inventory_ui.visible:
		state_machine.change_to("Inventory")
		return
