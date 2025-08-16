extends CharacterBody2D
signal dead
signal is_attacking

# Stats
var health = 100
var max_health = 100
var damage = 10
var attack_speed = 1.0
var num_enemies_strike = 1.0
var move_speed = 400

# Functions
func take_damage(amount):
	health -= amount
	if health <= 0:
		dead.emit()

func increase_max_health(amount):
	max_health += amount
	
func increase_damage(amount):
	damage += amount
	
func increase_attack_speed(amount):
	attack_speed += amount
	$AnimatedSprite2D.speed_scale = attack_speed
	$AttackTimer.wait_time = 1.0/attack_speed
	
func increase_attack_num_enemies(amount):
	num_enemies_strike += amount
	
func die():
	# Handle the player's death here (e.g., show a game over screen)
	print("Player has died!")

func _ready():
	$AnimatedSprite2D.speed_scale = attack_speed
	$AttackTimer.wait_time = 1.0/attack_speed
	
func _process(delta):
	var velocity = Vector2.ZERO # The mob's movement vector.
	
	velocity.x -= 1

	velocity = velocity.normalized() * move_speed
	$AnimatedSprite2D.play()
	

func start(pos):
	position = pos
	show()
	$Collision.disabled = false	
	


func _on_attack_timer_timeout() -> void:
	emit_signal("is_attacking", damage, num_enemies_strike)


func _on_area_entered(area: Area2D) -> void:
	$AnimatedSprite2D.animation = "attack"
	if $AttackTimer.is_stopped():
		$AttackTimer.start() # Replace with function body.


func _on_area_exited(area: Area2D) -> void:
	$AttackTimer.stop()
	$AnimatedSprite2D.animation = "idle" # Replace with function body.
