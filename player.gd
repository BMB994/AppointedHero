extends CharacterBody2D
signal dead
signal is_attacking

# Stats
var health = 100
var max_health = 100
var damage = 25
var attack_speed = 1.0
var num_enemies_strike = 1.0
var move_speed = 400

# Functions
func take_damage(amount):
	health -= amount
	$HealthBar.value = health
	if health <= 0:
		dead.emit()

func increase_max_health(amount):
	max_health =  max_health + max_health * amount
	
func increase_damage(amount):
	damage += amount
	
func increase_attack_speed(amount):
	attack_speed = attack_speed * amount
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
	$HealthBar.max_value = max_health
	$HealthBar.value = max_health
	
func _process(delta):

	$AnimatedSprite2D.play()
	
func start(pos):
	position = pos
	show()
	$Collision.disabled = false	
	
func _on_attack_timer_timeout() -> void:
	emit_signal("is_attacking", damage, num_enemies_strike)

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	$AnimatedSprite2D.animation = "attack"
	if $AttackTimer.is_stopped():
		emit_signal("is_attacking", damage, num_enemies_strike)
		$AttackTimer.start()
		$ReturnToIdleTimer.stop()

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	$AttackTimer.stop()
	$ReturnToIdleTimer.start()

func _on_return_to_idle_timer_timeout() -> void:
	$AnimatedSprite2D.animation = "idle"

func _reset_player():
	$AnimatedSprite2D.speed_scale = attack_speed
	$AttackTimer.wait_time = 1.0/attack_speed
	$HealthBar.max_value = max_health
	$HealthBar.value = max_health
	health = max_health
