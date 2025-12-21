extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_count: int = 5
@export var spawn_area: Vector2 = Vector2(10, 10)

func _ready():
	for i in range(0):
		spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	# Random position within the area
	var random_x = randf_range(-spawn_area.x / 2, spawn_area.x / 2)
	var random_z = randf_range(-spawn_area.y / 2, spawn_area.y / 2)
	enemy.global_position = global_position + Vector3(random_x, 0.5, random_z)
