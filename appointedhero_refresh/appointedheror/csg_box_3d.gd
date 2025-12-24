extends CSGBox3D

@export var enemy_scene: PackedScene
@export var spawn_count: int = 3

func _ready():
	visible = false
	# We wait one tiny frame to make sure the Main scene is fully loaded
	# before we start throwing enemies into it.
	await get_tree().process_frame
	
	#for i in range(spawn_count):
		#spawn_in_zone()

func spawn_in_zone():
	if not enemy_scene: return
	
	var enemy = enemy_scene.instantiate()
	
	# 1. Calculate the position
	var box_size = self.size
	var random_x = randf_range(-box_size.x/2, box_size.x/2)
	var random_z = randf_range(-box_size.z/2, box_size.z/2)
	# Use the Y of the box so they spawn at the box's height
	var spawn_pos = global_position + Vector3(random_x, 0, random_z)
	
	# 2. Add to the scene tree
	get_parent().add_child(enemy)
	
	# 3. FORCE the position now that it's in the tree
	enemy.global_position = spawn_pos
