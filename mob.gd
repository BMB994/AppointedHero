extends CharacterBody2D

signal dead_mob
signal is_attacking

# Properties
var health = 100
var max_health = 100
var damage = 10
var attack_speed = 1.0
var soul_worth = 1.0
var mob_speed = 1500
var is_attacking_player = false
var blocked = false

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

#func _physics_process(delta):
	## Set velocity based on whether the mob is attacking
	#if not blocked:
		#velocity = Vector2(-mob_speed, 0)
		#
	#else:
		#velocity = Vector2.ZERO
	#
	##if velocity != Vector2.ZERO:
		##$HealthBar.indeterminate = true
	##else:
		##$HealthBar.indeterminate = false
	#
	## Move the mob and handle collisions
	#move_and_slide()
func _physics_process(delta):
	# Tell the raycast to check for collisions
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		# Something is in front of us. Get a reference to it.
		var collider = $RayCast2D.get_collider()
		
		if collider.is_in_group("player"):
		# A player is in front, so attack
			velocity = Vector2.ZERO
			attack()
		elif collider.is_in_group("mob"):
			# Another mob is in front, stop and wait in line
			velocity = Vector2.ZERO
			$AnimatedSprite2D.animation = "idle"
		else:
			# It's not a player or mob, so keep moving
			velocity = Vector2(-mob_speed, 0)
			$AnimatedSprite2D.animation = "walk"
	else:
		# Nothing is in front, move forward
		velocity = Vector2(-mob_speed, 0)
		$AnimatedSprite2D.animation = "walk"
	
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

	## Stop attacking and start walking again
	#if body.is_in_group("player"):
		#is_attacking_player = false
	$AnimatedSprite2D.animation = "walk"
	blocked = false
	is_attacking_player = false
		#$AnimatedSprite2D.play()
