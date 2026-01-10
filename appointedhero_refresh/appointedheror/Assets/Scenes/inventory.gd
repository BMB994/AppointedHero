extends State

func enter():
	player.anim_state.travel("player_Idle")
	player.velocity = Vector3.ZERO

func physics_update(_delta: float):

	if not player.inventory_ui.visible:
		state_machine.change_to("Idle")
