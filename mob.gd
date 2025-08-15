extends RigidBody2D

signal dead_mob
signal is_attacking


var health = 100
var max_health = 100
var damage = 1
var attack_speed = 1.0
var soul_worth = 1.0
var mob_speed = 100
var screen_size

# Functions
func take_damage(amount):
	health -= amount
	if health <= 0:
		dead_mob.emit()

func increase_max_health(amount):
	max_health += amount
	
func increase_damage(amount):
	damage += amount
	
func increase_attack_speed(amount):
	attack_speed += amount
	$AnimatedSprite2D.speed_scale = attack_speed
	$AttackTimer.wait_time = 1.0/attack_speed
	
func increase_soul_worth(amount):
	soul_worth += amount
	
func die():
	emit_signal("dead_mob", soul_worth)
	queue_free()
	
func _ready():
	$AnimatedSprite2D.speed_scale = attack_speed
	$AttackTimer.wait_time = 1.0/attack_speed
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.animation = "walk"
	
func _physics_process(delta):
	if $AnimatedSprite2D.animation == "walk":
		linear_velocity = Vector2(-mob_speed, 0)
	else:
		linear_velocity = Vector2(0, 0)
	
	$AnimatedSprite2D.play()


func _on_attack_timer_timeout() -> void:
	emit_signal("is_attacking", damage)

func attack():
	$AnimatedSprite2D.animation = "attack"
	if $AttackTimer.is_stopped():
		$AttackTimer.start() # Replace with function body.


func _on_area_exited(area: Area2D) -> void:
	$AttackTimer.stop()
	$AnimatedSprite2D.animation = "walk"
	
func _on_area_2d_body_entered(body):
	
	if body.is_in_group("player"):
		attack()
	else:
		$AnimatedSprite2D.animation = "walk"
