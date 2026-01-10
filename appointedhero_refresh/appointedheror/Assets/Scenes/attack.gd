extends State

func enter():
	if Input.is_action_just_pressed("heavy_attack"):
		start_attack("player_Melee_1H_Attack_Stab_Heavy", player.HEAVY_ATK_LUNG)
	else:
		start_attack("player_Melee_1H_Attack_Slice_Diagonal_Light", player.LIGHT_ATK_LUNG)

func start_attack(anim_name: String, lunge: float):
	player.perform_attack(anim_name)
	
	if player.is_locked_on and player.target_enemy:
		player.rotate_towards_target(player.target_enemy.global_position, 0, true)
	
	player.velocity = player.slected_char.global_transform.basis.z * lunge

func physics_update(_delta: float):
	player.velocity.x = move_toward(player.velocity.x, 0, 0.5)
	player.velocity.z = move_toward(player.velocity.z, 0, 0.5)
	
	if not "Attack" in player.anim_state.get_current_node():
		state_machine.change_to("Idle")
