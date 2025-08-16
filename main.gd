extends Node
@export var mob_scene: PackedScene
var mob_count
var max_mob_count

func _ready() -> void:
	
	$Player.start($PlayerPosition.position)
	var mob = mob_scene.instantiate()
	mob.start($MobStartPosition.position)
	$MobSpawnTimer.start()
	
	
	add_child(mob)
	mob_count = 1

func _process(delta: float) -> void:
	pass


func _on_mob_spawn_timer_timeout() -> void:
	
	if mob_count < 10:
		var mob = mob_scene.instantiate()
		mob.start($MobStartPosition.position)
	
	
		add_child(mob)
		mob_count = mob_count + 1 # Replace with function body.
