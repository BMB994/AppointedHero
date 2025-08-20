extends Area2D

var speed = 1400
var target_position = Vector2.ZERO
var damage = 1000

func set_target(target: Vector2):
	target_position = target
	#look_at(target)

func start(pos, lvl):
	position = pos
	
	if(lvl == 1):
		$AnimatedSprite2D.animation = "lightning_one"
		damage = 150
	elif(lvl == 2):
		$AnimatedSprite2D.animation = "lightning_two"
		damage = 300
	elif(lvl == 3):
		$AnimatedSprite2D.animation = "lightning_three"
		damage = 1000
	elif(lvl == 4):
		$AnimatedSprite2D.animation = "lightning_four"
		damage = 1000
	else:
		$AnimatedSprite2D.animation = "lightning_one"
	show()

func _ready() -> void:
	$AnimatedSprite2D.animation = "lightning_one"
	$AnimatedSprite2D.play()
	
func _increase_arrow_damage(amount):
	damage = damage*amount
	
func _process(delta):
	# Move the arrow towards its target
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta

	# If the arrow is close enough to the target, delete it
	if global_position.distance_to(target_position) < 5:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# This assumes your mobs have a "take_damage" function
	if body.is_in_group("mob"):
		body.take_damage(damage) # Example damage value
	queue_free()
