# State.gd (The Base Class)
extends Node
class_name State

var player: Entity
var state_machine: StateMachine

func enter():
	pass # Runs once when switching TO this state

func exit():
	pass # Runs once when switching AWAY from this state

func update(delta: float):
	pass # Runs every frame (like _process)

func physics_update(delta: float):
	pass # Runs every physics frame (like _physics_process)
