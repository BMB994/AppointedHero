extends CharacterBody2D

signal dead_mob
signal is_attacking

# Properties
var health = 100
var damage = 1
var attack_speed = 1.0
var soul_worth = 1.0
var mob_speed = 400
var is_attacking_player = false

# Functions
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	emit_signal("dead_mob", soul_worth)
	queue_free()

func start(pos):
	position = pos
	show()

func _ready():
	$AnimatedSprite2D.speed_scale = attack_speed
	$AttackTimer.wait_time = 1.0 / attack_speed
	$AnimatedSprite2D.animation = "walk"
	$AnimatedSprite2D.play()

func _physics_process(delta):
	# Set velocity based on whether the mob is attacking
	if not is_attacking_player:
		velocity = Vector2(-mob_speed, 0)
	else:
		velocity = Vector2.ZERO
	
	# Move the mob and handle collisions
	move_and_slide()

func attack():
	# Change state to attacking
	if not is_attacking_player:
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

func _on_detection_area_body_exited(body):
	# Stop attacking and start walking again
	if body.is_in_group("player"):
		is_attacking_player = false
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.play()
