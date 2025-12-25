extends Control

@onready var item_list = find_child("ItemList")

# Call this whenever the inventory is opened
func _ready():
	self.hide() # Start hidden

func update_display(inventory_node: Node3D):
	# 1. Clear old buttons
	for child in item_list.get_children():
		child.queue_free()
	
	# 2. Look at every physical node in the 3D inventory
	for item in inventory_node.get_children():
		var btn = Button.new()
		btn.text = item.name # This will show "samurai_sword", etc.
		btn.custom_minimum_size.y = 40
		item_list.add_child(btn)
