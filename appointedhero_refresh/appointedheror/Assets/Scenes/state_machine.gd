extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}
var player: Entity

func init(_player: Entity):
	player = _player
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.player = player
			child.state_machine = self
	
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _physics_process(delta: float):
	if player and not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		
	if current_state:
		current_state.physics_update(delta)
	
	if player:
		player.move_and_slide()

func _process(delta: float):
	if current_state:
		current_state.update(delta)

func change_to(target_state_name: String):
	var new_state = states.get(target_state_name.to_lower())
	if not new_state:
		print("State ", target_state_name, " does not exist!")
		return
		
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()
