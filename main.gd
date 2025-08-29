extends Node

@export var mob_scene: PackedScene
@export var arrow_scene: PackedScene
@export var lightning_scene: PackedScene

var max_mob_count = 10
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
	$UpgradeScreen.hide()
	current_camera_pos = $CameraStartPosition.position
	
	#Removing camera setting for now
	#$Camera2D.set_main_screen($CameraStartPosition.position, camera_zoom_level)
	$Camera2D.set_middle()
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
	var mobs = get_tree().get_nodes_in_group("mob")
	dead_mobs = dead_mobs + 1
	soul_bank = soul_bank + mob_instance.soul_worth
	mobs.erase(mob_instance)
	if dead_mobs%level_count == 0 && dead_mobs != 0:
		level = level + 1
		# update the mobs in line
		
		for mob in mobs:
			mob._mob_difficult_scale(level)
	_update_HUD()
	
func _on_mob_spawn_timer_timeout() -> void:
	var mob_in_way = false
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
			if (mob.position.x > $MobStartPosition.position.x - 20):
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
	pass
	#Not sure I want the player to die
	#$Player.take_damage(damage)

func _update_HUD():
	$HUD.update_dead_count(dead_mobs)
	$HUD.update_soul_count(soul_bank)
	$HUD.update_level(level)
	
func _spawn_mob():
		var mob = mob_scene.instantiate()
		mob.start($MobStartPosition.position)
		# Level buffs
		mob._mob_difficult_scale(level)
		add_child(mob)
		mob.connect("dead_mob", _on_mob_dead)
		mob.connect("is_attacking", _on_mob_is_attacking)
	
func _on_player_dead() -> void:
	_pause_game()

func _pause_game():
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	
	#Clear mobs
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.queue_free()
	
	#Clear arrows
	var arrows = get_tree().get_nodes_in_group("Arrow")
	for arrow in arrows:
		arrow.queue_free()
		
	#Clear lightning
	var lights = get_tree().get_nodes_in_group("Lightning")
	for light in lights:
		light.queue_free()
		
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
	
	#Removing camera setting for now
	#$Camera2D.set_main_screen(current_camera_pos, camera_zoom_level)
	$Camera2D.set_middle()
	if(arrows_unlocked):
		$ArrowSpawnTimer.start()

func _reset():
	#Stop timers
	var timers = get_tree().get_nodes_in_group("timer")
	for timeys in timers:
		timeys.stop()
		
	#Clear arrows
	var arrows = get_tree().get_nodes_in_group("Arrow")
	for arrow in arrows:
		arrow.queue_free()
		
	#Clear lightning
	var lights = get_tree().get_nodes_in_group("Lightning")
	for light in lights:
		light.queue_free()
		
	#Clear mobs
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.queue_free()
	

		
	dead_mobs = 0
	level = 1
	_update_HUD()
	
	if(arrows_unlocked):
		$ArrowSpawnTimer.start()
		
	if(lightning_unlocked):
		$LightningSpawnTimer.start()
		
	$MobSpawnTimer.start()
	
func _on_upgrade_screen_upgrade_attack_speed() -> void:
	$Player.increase_attack_speed(2)

func _on_upgrade_screen_upgrade_damage_button() -> void:
	$Player.increase_damage(100)

func _on_arrow_spawn_timer_timeout() -> void:
	var arrows = get_tree().get_nodes_in_group("Arrow")
	var mobs = get_tree().get_nodes_in_group("mob")
	if mobs.size() > arrows.size():
		# Pick a random mob as the target
		var random_mob = mobs[randi() % mobs.size()]

		# Create a new arrow instance
		var arrow_instance = arrow_scene.instantiate()
		add_child(arrow_instance)

		# Set the starting position and target for the arrow
		arrow_instance.start($ArrowPosition.position, arrow_level)
		arrow_instance.set_target(random_mob.global_position)

func _on_upgrade_screen_arrows() -> void:
	$ArrowSpawnTimer.start()
	arrows_unlocked = true
	
	#Removing camera setting for now
	#if(camera_zoom_level > arrow_camera_zoom_dis):
		#camera_zoom_level = arrow_camera_zoom_dis
		#
	#if(current_camera_pos.x > $CameraStartPosition.position.x + arrow_camera_setpoint.x):
		#current_camera_pos = $CameraStartPosition.position + arrow_camera_setpoint
		#$PlayerPosition.position = $PlayerPosition.position + arrow_camera_setpoint
		#set_player_pos()
	
func _on_upgrade_screen_arrow_level() -> void:
	if(arrow_level < 3):
		arrow_level = arrow_level + 1

func _on_upgrade_screen_arrow_speed() -> void:
	$ArrowSpawnTimer.wait_time = $ArrowSpawnTimer.wait_time/2

func _on_upgrade_screen_lightning() -> void:
	$LightningSpawnTimer.start()
	lightning_unlocked = true

	#Removing camera setting for now
	#if(camera_zoom_level > lightning_camera_zoom_dis):
		#camera_zoom_level = lightning_camera_zoom_dis
		#
	#if(current_camera_pos.x > $CameraStartPosition.position.x + lightning_camera_setpoint.x):
		#current_camera_pos = screen_center_pos
		#$PlayerPosition.position = Vector2(screen_center_pos.x/2, $PlayerPosition.position.y)
		#set_player_pos()
		
func _on_lightning_spawn_timer_timeout() -> void:
	var lightnings = get_tree().get_nodes_in_group("Lightning")
	var mobs = get_tree().get_nodes_in_group("mob")
	if mobs.size() > 0 && lightnings.size() <= 1:
		
		# Create a new lightning instance
		var lightning_instance = lightning_scene.instantiate()
		var offset = Vector2((randi() % 100)*10, 0)
		# Set the starting position and target for the arrow
		lightning_instance.start($LightningPosition.position + offset, lightning_level)
		lightning_instance.set_target($LightningPosition.position + Vector2(offset.x,800))
		add_child(lightning_instance)

func _on_upgrade_screen_lightning_upgrade() -> void:
	if(lightning_level < 3):
		lightning_level = lightning_level + 1

func set_player_pos():
	$Player.position = $PlayerPosition.position

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_new_game_pressed() -> void:
	_reset()

func _on_upgrade_pressed() -> void:
	$UpgradeScreen.show()
