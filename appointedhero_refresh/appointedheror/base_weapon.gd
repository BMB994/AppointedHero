extends Node3D

class_name BaseWeapon

@export var damage: float = 1.0
@export var light_damage = 10.0
@export var heavy_damage = 20.0
@export var attack_speed: float = 1.0
@export var animation_name: String = "sword_attack_one"
@onready var anim_player = $AnimationPlayer
@onready var hitbox: Area3D = $Pivot/Hitbox
var owner_entity: Entity = null

func use(type_attack: String = "default"):
	damage = 0
	if type_attack == "light":
		damage = light_damage
	elif type_attack == "heavy":
		damage = heavy_damage
		
	if anim_player.has_animation(animation_name):
		anim_player.play(animation_name)
	else:
		print("Warning: Animation " + animation_name + " not found on this weapon!")
		
func enable_hitbox():
	if hitbox:
		hitbox.monitoring = true

func disable_hitbox():
	if hitbox:
		hitbox.monitoring = false
		hit_entities.clear() 
	
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
	
	if body is Entity and body != owner_entity:
		if not body in hit_entities:
			body.take_damage(damage)
			hit_entities.append(body)
