extends Node
@export var mob_scene: PackedScene

var max_mob_count = 10
var mob_array = []
var dead_mobs = 0
var soul_bank = 0
var level = 1
var level_count = 10

func _ready() -> void:
	$DeathControlNode.hide()
	
	# Start Player and spawn first mob
	$Player.start($PlayerPosition.position)
	_spawn_mob()
	
	# Start timers
	$MobSpawnTimer.start()

	# Update HUD
	_update_HUD()

func _process(delta: float) -> void:
	if Input.is_action_just_released("attack"):
		$Player.increase_damage(10)
	if Input.is_action_just_released("increase_speed"):
		$Player.increase_attack_speed(0.1)
		
func _on_mob_dead(mob_instance):

	dead_mobs = dead_mobs + 1
	soul_bank = soul_bank + mob_instance.soul_worth
	mob_array.erase(mob_instance)
	if dead_mobs%level_count == 0 && dead_mobs != 0:
		level = level + 1
		# update the mobs in line
		for i in range (mob_array.size()):
			mob_array[i]._mob_difficult_scale(level)
	_update_HUD()
	
func _on_mob_spawn_timer_timeout() -> void:
	
	if mob_array.size() < max_mob_count:
		_spawn_mob()	

func _on_player_is_attacking(damage: int, num_enemies_strike: int) -> void:
	mob_array[0].take_damage(damage)
	
func _on_mob_is_attacking(damage: int) -> void:
	$Player.take_damage(damage)

func _update_HUD():
	$HUD.update_dead_count(dead_mobs)
	$HUD.update_soul_count(soul_bank)
	$HUD.update_level(level)
	
func _spawn_mob():
		var mob = mob_scene.instantiate()
		mob_array.append(mob)
		mob.start($MobStartPosition.position)
		# Level buffs
		mob._mob_difficult_scale(level)
		add_child(mob)
		mob.connect("dead_mob", _on_mob_dead)
		mob.connect("is_attacking", _on_mob_is_attacking)
	
func _on_player_dead() -> void:
	_pause_game()
	if(mob_array.size() > 0):
		for mob in mob_array:
			if is_instance_valid(mob):
				mob.queue_free()
	
	mob_array.clear()
	$DeathControlNode.show()

func _on_death_control_node_upgrade_health_button() -> void:
	$Player.increase_max_health(1)

func _on_death_control_node_new_game() -> void:
	_resume_game()
	$Player._reset_player()
	$DeathControlNode.hide()

func _pause_game():
	$MobSpawnTimer.stop()
	$Player.hide()
	
func _resume_game():
	dead_mobs = 0
	level = 1
	_update_HUD()
	$MobSpawnTimer.start()
	$Player.show()

func _on_death_control_node_upgrade_attack_speed() -> void:
	$Player.increase_attack_speed(2)

func _on_death_control_node_exit() -> void:
	get_tree().quit()

func _on_death_control_node_upgrade_damage_button() -> void:
	$Player.increase_damage(100)
