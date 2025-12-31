extends Control

@onready var item_list = $MarginContainer/HBoxContainer/LeftSide/ItemList
@onready var right_hand_slot = $MarginContainer/HBoxContainer/Middle/RightHandSlot
@onready var left_hand_slot = $MarginContainer/HBoxContainer/Middle/LeftHandSlot

@onready var rucksack_grid = $MarginContainer/HBoxContainer/InventorySlots
@onready var equipment_grid = $MarginContainer/HBoxContainer/EquipmentSlots
var player

const COLS = 6
const ROWS = 8

func _ready():
	player = get_tree().get_first_node_in_group("player")
	rucksack_grid.setup_grid(COLS, ROWS, 12)
	if player:
		player.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(rucksack: Array[ItemData], equipment: Dictionary):
	_update_rucksack_ui(rucksack)
	_update_equipment_ui(equipment)
	
func _update_rucksack_ui(rucksack_array: Array[ItemData]):
	var slots = rucksack_grid.get_children()
	
	for i in range(slots.size()):
		var slot = slots[i]
		
		# 1. Boilerplate: Disconnect old signals to avoid "double equipping"
		if slot.pressed.is_connected(_on_ruck_slot_pressed):
			slot.pressed.disconnect(_on_ruck_slot_pressed)
		
		# 2. Check Capacity
		if i < rucksack_grid.current_capacity:
			# 3. Check if there is actually an item at this index
			if i < rucksack_array.size():
				slot.display(rucksack_array[i])
				
				# 4. THE EQUIP TRIGGER: 
				# Connect the "A" button/Click to our equip function
				slot.pressed.connect(_on_ruck_slot_pressed.bind(i))
				
				# Ensure the controller can select this slot
				slot.focus_mode = Control.FOCUS_ALL
			else:
				# Slot is empty
				slot.display(null)
				# Optional: Allow focusing empty slots, or disable focus
				slot.focus_mode = Control.FOCUS_ALL 
		else:
			# Slot is locked/not yet unlocked
			slot.display(null)
			slot.focus_mode = Control.FOCUS_NONE

func _update_equipment_ui(equipment: Dictionary):
	_recursive_update_slots(equipment_grid, equipment)
	
func _recursive_update_slots(parent_node, equipment: Dictionary):
	for child in parent_node.get_children():
		if child is ItemSlot:
			var key = child.slot_name
			child.display(equipment.get(key))
			
			# ERROR FIX: Ensure we disconnect before reconnecting to avoid multiple calls
			if child.pressed.is_connected(_on_equipment_slot_pressed):
				child.pressed.disconnect(_on_equipment_slot_pressed)
			
			# Bind the specific key (e.g., "RIGHT_HAND") to this specific button
			child.pressed.connect(_on_equipment_slot_pressed.bind(key))
			
		elif child.get_child_count() > 0:
			_recursive_update_slots(child, equipment)
			
func _on_ruck_slot_pressed(index: int):
	if player:
		# Check if the player actually has an item at this index
		if index < player.ruck_sacked.size():
			print("Controller: Equipping item at index ", index)
			player.equip_from_inventory(index)
			
func _on_equipment_slot_pressed(slot_key: String):
	if player:
		player.unequip_item(slot_key)

func focus_first_slot():
	# Grab the first available rucksack slot
	if rucksack_grid.get_child_count() > 0:
		rucksack_grid.get_child(0).grab_focus()
