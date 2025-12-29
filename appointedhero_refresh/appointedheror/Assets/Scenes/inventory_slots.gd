extends GridContainer

const ITEM_SLOT_SCENE = preload("res://Assets/Scenes/item_slot.tscn")

@export var rows: int = 8
@export var cols: int = 6
var current_capacity: int = 12

func setup_grid(grid_cols: int, grid_rows: int, capacity: int):
	self.columns = grid_cols
	
	# Clear any editor-placeholders
	for child in get_children():
		child.queue_free()
		
	for i in range(grid_cols * grid_rows):
		var slot = ITEM_SLOT_SCENE.instantiate()
		add_child(slot)
		
		if i < capacity:
			slot.display(null)
