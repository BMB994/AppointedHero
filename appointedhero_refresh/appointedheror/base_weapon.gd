extends Node3D

class_name BaseWeapon

@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var animation_name: String = "sword_attack_one" # Set a default name
@onready var anim_player = $AnimationPlayer
@onready var hitbox: Area3D = $Pivot/Hitbox

func use():
	if anim_player.has_animation(animation_name):
		anim_player.play(animation_name)
	else:
		print("Warning: Animation " + animation_name + " not found on this weapon!")
		
func enable_hitbox():
	if hitbox:
		hitbox.monitoring = true
		print("Hitbox ON")

func disable_hitbox():
	if hitbox:
		hitbox.monitoring = false
		# Clear the list of things we've hit this swing 
		# so we can hit them again next swing
		hit_entities.clear() 
		print("Hitbox OFF")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start with it OFF so you don't kill people just by walking into them
	if hitbox:
		hitbox.monitoring = false
		hitbox.body_entered.connect(_on_hitbox_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# A list to make sure we don't hit the same guy 5 times in ONE swing
var hit_entities = []

func _on_hitbox_body_entered(body):
	# 1. Make sure it's an Entity and not the person holding the sword
	if body is Entity and body != get_parent().get_parent():
		# 2. Check Factions (Stardew Style)
		var attacker = get_parent().get_parent()
		#if body.faction != attacker.faction:
			## 3. Prevent double-damage in one swing
		if not body in hit_entities:
			body.take_damage(damage)
			hit_entities.append(body)
