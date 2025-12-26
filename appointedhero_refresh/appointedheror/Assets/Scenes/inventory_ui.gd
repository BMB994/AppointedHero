extends Control

@onready var item_list = $MarginContainer/HBoxContainer/LeftSide/ItemList


func update_display(ruck_sack_array: Array[ItemData], player: Entity):
	# 1. Clear old buttons
	for child in item_list.get_children():
		item_list.remove_child(child)
		child.queue_free()
	
	# 2. Add new buttons
	for i in range(ruck_sack_array.size()):
		var item = ruck_sack_array[i]
		var btn = Button.new()
		btn.text = item.display_name
		item_list.add_child(btn)
		
		# Connect to player (Step 2 logic)
		#btn.pressed.connect(player.equip_from_inventory.bind(i))

	if item_list.get_child_count() > 0:
		item_list.get_child(0).grab_focus()
