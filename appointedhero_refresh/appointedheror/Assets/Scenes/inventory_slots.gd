extends GridContainer

const ITEM_SLOT_SCENE = preload("res://Assets/Scenes/item_slot.tscn")

@export var rows: int = 8
@export var cols: int = 6
var current_capacity: int = 12

func _ready():
	# Create the full 6x8 physical grid
	for i in range(rows * cols):
		var slot = ITEM_SLOT_SCENE.instantiate()
		add_child(slot)
		
		# Visually lock slots that are beyond current capacity
		if i >= current_capacity:
			slot.modulate = Color(0.2, 0.2, 0.2, 0.5) # Dark/Hidden
			slot.disabled = true # Prevent interaction
