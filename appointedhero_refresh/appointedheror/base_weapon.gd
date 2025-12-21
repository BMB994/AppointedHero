extends Node3D

class_name BaseWeapon

@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var animation_name: String = "sword_attack_one" # Set a default name
@onready var anim_player = $AnimationPlayer

func use():
	if anim_player.has_animation(animation_name):
		anim_player.play(animation_name)
	else:
		print("Warning: Animation " + animation_name + " not found on this weapon!")
		
func enable_hitbox():
	# We will add logic here later to turn on the Area3D
	print("Hitbox ON")

func disable_hitbox():
	# We will add logic here later to turn off the Area3D
	print("Hitbox OFF")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
