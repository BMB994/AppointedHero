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
var lightning_level = 0
var camera_zoom_level = 3
var arrow_camera_zoom_dis = 1.50
var arrow_camera_setpoint = Vector2(-200,0)
var lightning_camera_zoom_dis = 1
var lightning_camera_setpoint = Vector2(-400,0)
var current_camera_pos
var screen_center_pos

#TODO Write function to start/stop all effect timers
func _ready() -> void:
	$DeathControlNode.hide()
	current_camera_pos = $CameraStartPosition.position
	$Camera2D.set_main_screen($CameraStartPosition.position, camera_zoom_level)
	screen_center_pos = $Camera2D.get_screen_center_position()
	
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
		var mobbies = get_tree().get_nodes_in_group("mob")
		var counter = 0
		for mob in mobbies:
			counter =  + 1
			mob.take_damage(damage)
			if(counter == num_enemies_strike):
				break;
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

func _on_death_control_node_upgrade_health_button() -> void:
	$Player.increase_max_health(1)

func _on_death_control_node_new_game() -> void:
	_resume_game()
	$Player._reset_player()
	$DeathControlNode.hide()

func _pause_game():
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	
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
	$Camera2D.set_middle()
	$DeathControlNode.show()
	$MobSpawnTimer.stop()
	$Player.hide()
	$ArrowSpawnTimer.stop()
	

func _resume_game():
	dead_mobs = 0
	level = 1
	_update_HUD()
	$MobSpawnTimer.start()
	set_player_pos()
	$Player.show()
	$Camera2D.set_main_screen(current_camera_pos, camera_zoom_level)
	
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
	if(camera_zoom_level > arrow_camera_zoom_dis):
		camera_zoom_level = arrow_camera_zoom_dis
		
	if(current_camera_pos.x > $CameraStartPosition.position.x + arrow_camera_setpoint.x):
		current_camera_pos = $CameraStartPosition.position + arrow_camera_setpoint
		$PlayerPosition.position = $PlayerPosition.position + arrow_camera_setpoint
		set_player_pos()
	
func _on_death_control_node_arrow_level() -> void:
	if(arrow_level < 3):
		arrow_level = arrow_level + 1

func _on_death_control_node_arrow_speed() -> void:
	$ArrowSpawnTimer.wait_time = $ArrowSpawnTimer.wait_time/2

func _on_death_control_node_lightning() -> void:
	$LightningSpawnTimer.start()
	lightning_unlocked = true

	if(camera_zoom_level > lightning_camera_zoom_dis):
		camera_zoom_level = lightning_camera_zoom_dis
		
	if(current_camera_pos.x > $CameraStartPosition.position.x + lightning_camera_setpoint.x):
		current_camera_pos = screen_center_pos
		$PlayerPosition.position = Vector2(screen_center_pos.x/2, $PlayerPosition.position.y)
		set_player_pos()
		
func _on_lightning_spawn_timer_timeout() -> void:
	if mob_array.size() > 0:
		# Create a new lightning instance
		var lightning_instance = lightning_scene.instantiate()
		add_child(lightning_instance)
		var offset = Vector2((randi() % 100)*10, 0)
		# Set the starting position and target for the arrow
		lightning_instance.start($LightningPosition.position + offset, lightning_level)
		lightning_instance.set_target($LightningPosition.position + Vector2(offset.x,800))

func _on_death_control_node_lightning_upgrade() -> void:
	if(lightning_level < 3):
		lightning_level = lightning_level + 1

func set_player_pos():
	$Player.position = $PlayerPosition.position
