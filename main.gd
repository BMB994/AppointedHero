extends Node

@export var mob_scene: PackedScene
@export var arrow_scene: PackedScene
@export var lightning_scene: PackedScene

var max_mob_count = 10
var mob_array = []

var dead_mobs = 0
var soul_bank = 0
var level = 1
var level_count = 10
var arrows_unlocked = false
var lightning_unlocked = false
var arrow_level = 0

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
	pass
		
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
	var mob_in_way = false
	for i in range (mob_array.size()):
			if (mob_array[i].position.x > $MobStartPosition.position.x - 10):
				mob_in_way = true
	if !mob_in_way:
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
	# Clear mobs
	if(mob_array.size() > 0):
		for mob in mob_array:
			if is_instance_valid(mob):
				mob.queue_free()
	
	mob_array.clear()
	
	#Clear arrows
	var arrows = get_tree().get_nodes_in_group("Arrow")
	for arrow in arrows:
		arrow.queue_free()
		
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
	$ArrowSpawnTimer.stop()
	
func _resume_game():
	dead_mobs = 0
	level = 1
	_update_HUD()
	$MobSpawnTimer.start()
	$Player.show()
	
	if(arrows_unlocked):
		$ArrowSpawnTimer.start()

func _on_death_control_node_upgrade_attack_speed() -> void:
	$Player.increase_attack_speed(2)

func _on_death_control_node_exit() -> void:
	get_tree().quit()

func _on_death_control_node_upgrade_damage_button() -> void:
	$Player.increase_damage(100)

func _on_arrow_spawn_timer_timeout() -> void:
	if mob_array.size() > 0:
		# Pick a random mob as the target
		var random_mob = mob_array[randi() % mob_array.size()]

		# Create a new arrow instance
		var arrow_instance = arrow_scene.instantiate()
		add_child(arrow_instance)

		# Set the starting position and target for the arrow
		arrow_instance.start($ArrowPosition.position, arrow_level)
		arrow_instance.set_target(random_mob.global_position)

func _on_death_control_node_arrows() -> void:
	$ArrowSpawnTimer.start()
	arrows_unlocked = true
	
func _on_death_control_node_arrow_level() -> void:
	if(arrow_level < 3):
		arrow_level = arrow_level + 1

func _on_death_control_node_arrow_speed() -> void:
	$ArrowSpawnTimer.wait_time = $ArrowSpawnTimer.wait_time/2

func _on_death_control_node_lightning() -> void:
	$LightningSpawnTimer.start()
	lightning_unlocked = true

func _on_lightning_spawn_timer_timeout() -> void:
	if mob_array.size() > 0:
		# Create a new lightning instance
		var lightning_instance = lightning_scene.instantiate()
		add_child(lightning_instance)
		var offset = Vector2((randi() % 100)*10, 0)
		# Set the starting position and target for the arrow
		lightning_instance.start($LightningPosition.position + offset, 1)
		lightning_instance.set_target($LightningPosition.position + Vector2(offset.x,800))
