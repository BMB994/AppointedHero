extends Node


@export var mob_scene: PackedScene

func _ready() -> void:
	
	$Player.start($PlayerPosition.position)
	var mob = mob_scene.instantiate()
	
	mob.start($MobStartPosition.position)
	add_child(mob)

func _process(delta: float) -> void:
	pass
