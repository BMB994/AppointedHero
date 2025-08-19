extends CharacterBody2D

signal dead_mob
signal is_attacking

# Properties
var health = 100
var max_health = 1000
var damage = 100
var attack_speed = 1.0
var soul_worth = 1.0
var mob_speed = 1500
var is_attacking_player = false
var waiting_in_line = false

func _mob_difficult_scale(level):
	soul_worth = soul_worth * level
	max_health = max_health * level * 0.7
	damage = damage * level #* 0.15
	
func take_damage(amount):
	health -= amount
	$HealthBar.value
	if health <= 0:
		die()

func die():
	emit_signal("dead_mob", self)
	queue_free()

func start(pos):
	position = pos
	show()

func _ready():
	$AnimatedSprite2D.speed_scale = attack_speed
	$AttackTimer.wait_time = 1.0 / attack_speed
	$AnimatedSprite2D.animation = "walk"
	$AnimatedSprite2D.play()
	$HealthBar.max_value = max_health
	$HealthBar.value = max_health
	health = max_health

func _physics_process(delta):
	# Set velocity based on whether the mob is attacking
	if not is_attacking_player && not waiting_in_line:
		velocity = Vector2(-mob_speed, 0)
		
	else:
		velocity = Vector2.ZERO
	
	#if velocity != Vector2.ZERO:
		#$HealthBar.indeterminate = true
	#else:
		#$HealthBar.indeterminate = false
	
	# Move the mob and handle collisions
	move_and_slide()

func _process(delta):
	$HealthBar.value = health
		
func attack():
	# Change state to attacking
	if not is_attacking_player:
		emit_signal("is_attacking", damage)
		is_attacking_player = true
		$AnimatedSprite2D.animation = "attack"
		$AnimatedSprite2D.play()
		$AttackTimer.start()

func _on_attack_timer_timeout() -> void:
	# Deal damage to the player
	emit_signal("is_attacking", damage)

func _on_detection_area_body_entered(body):
	# Assumes you have an Area2D named "detection_area"
	if body.is_in_group("player"):
		attack()
		waiting_in_line = false
	elif body.is_in_group("mob"):
		waiting_in_line = true	

func _on_detection_area_body_exited(body):
	## Stop attacking and start walking again
	#if body.is_in_group("player"):
		#is_attacking_player = false
	$AnimatedSprite2D.animation = "walk"
	waiting_in_line = false
	is_attacking_player = false
		#$AnimatedSprite2D.play()
