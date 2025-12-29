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
		
		# Only update if the slot is within the player's current capacity
		if i < rucksack_grid.current_capacity:
			if i < rucksack_array.size():
				slot.display(rucksack_array[i])
			else:
				slot.display(null)

func _update_equipment_ui(equipment: Dictionary):
	_recursive_update_slots(equipment_grid, equipment)
	
	
func _recursive_update_slots(parent_node, equipment):
	for child in parent_node.get_children():
		if child is ItemSlot:
			# Use the EXPORT variable we created, not the node name!
			var key = child.slot_name 
			
			if key != "": # Make sure we actually set a name in the inspector
				child.display(equipment.get(key))
				
		elif child.get_child_count() > 0:
			_recursive_update_slots(child, equipment)

	#if data:
		#if node is Button:
			#node.text = data.display_name
			#node.icon = data.icon
		#elif node is TextureButton:
			#node.texture_normal = data.icon
		#node.tooltip_text = data.display_name
	#else:
		#if node is Button:
			#node.text = placeholder_text
			#node.icon = null
		#elif node is TextureButton:
			#node.texture_normal = null
