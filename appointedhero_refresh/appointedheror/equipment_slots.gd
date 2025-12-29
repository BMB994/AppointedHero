extends GridContainer

const ITEM_SLOT_SCENE = preload("res://Assets/Scenes/item_slot.tscn")

@export var rows: int = 3
@export var cols: int = 3

func _ready() -> void:
	self.columns = cols
	
	# Clear any editor-placeholders
	for child in get_children():
		child.queue_free()
		
	for i in range(cols * rows):
		var slot = ITEM_SLOT_SCENE.instantiate()
		add_child(slot)
		
