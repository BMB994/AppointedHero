extends Node
@export var mob_scene: PackedScene
var mob_count = 0
var max_mob_count = 10
var mob_array = []

#TODO: Add function to spawn a mob and clean the code up

func _ready() -> void:
	
	$Player.start($PlayerPosition.position)
	var mob = mob_scene.instantiate()
	mob_array.append(mob)
	mob.start($MobStartPosition.position)
	$MobSpawnTimer.start()
	add_child(mob)
	mob.dead_mob.connect(_on_mob_dead)
	mob_count = 1

func _process(delta: float) -> void:
	if Input.is_action_just_released("attack"):
		$Player.increase_damage(10)
	if Input.is_action_just_released("increase_speed"):
		$Player.increase_attack_speed(0.1)

func _on_mob_dead(mob_instance):
	# Remove the specific mob instance from the array
	mob_array.erase(mob_instance)
	print("A mob died. Mobs left: ", mob_array.size())	
	
func _on_mob_spawn_timer_timeout() -> void:
	
	if mob_array.size() < max_mob_count:
		var mob = mob_scene.instantiate()
		mob_array.append(mob)
		mob.start($MobStartPosition.position)
		add_child(mob)
		mob.connect("dead_mob", _on_mob_dead)
		


func _on_player_is_attacking(damage: int, num_enemies_strike: int) -> void:
	mob_array[0].take_damage(damage)
