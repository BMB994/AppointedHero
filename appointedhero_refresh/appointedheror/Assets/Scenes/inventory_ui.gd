extends Control

@onready var rucksack_grid = $MarginContainer/HBoxContainer/InventorySlots
@onready var equipment_grid = $MarginContainer/HBoxContainer/EquipmentSlots
@onready var stats_section = $MarginContainer/HBoxContainer/Statscreen/SubViewport
@export var doll_scene: PackedScene
var current_doll: Node3D = null

var player

const COLS = 6
const ROWS = 8
func _on_visibility_changed():
	if visible:
		_spawn_doll()
	else:
		_despawn_doll()
func _ready():
	player = get_tree().get_first_node_in_group("player")
	rucksack_grid.setup_grid(COLS, ROWS, 12)
	if player:
		player.inventory_changed.connect(_on_inventory_changed)
func _process(delta):
	if visible:
		if is_instance_valid(current_doll):
			var rotate_dir = Input.get_axis("look_left", "look_right")
			if rotate_dir != 0:
				current_doll.rotate_y(rotate_dir * delta * 5.0)
		
func _on_inventory_changed(rucksack: Array[ItemData], equipment: Dictionary):
	_update_rucksack_ui(rucksack)
	_update_equipment_ui(equipment)
	
func _update_rucksack_ui(rucksack_array: Array[ItemData]):
	var slots = rucksack_grid.get_children()
	
	for i in range(slots.size()):
		var slot = slots[i]
		
		if i < rucksack_grid.current_capacity:
			slot.show()
			# Disconnect old signals to avoid double equipping
			if slot.pressed.is_connected(_on_ruck_slot_pressed):
				slot.pressed.disconnect(_on_ruck_slot_pressed)
		
			# 3. Check if there is an item at this index
			if i < rucksack_array.size():
				slot.display(rucksack_array[i])
				slot.pressed.connect(_on_ruck_slot_pressed.bind(i))
				slot.focus_mode = Control.FOCUS_ALL
			else:
				slot.display(null)
				slot.focus_mode = Control.FOCUS_ALL 
		else:
			# 4. LOCKED: Hide the slot so it doesn't show up in the grid at all
			slot.hide()
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
			player.equip_from_inventory(index)
			
func _on_equipment_slot_pressed(slot_key: String):
	if player:
		player.unequip_item(slot_key)

func focus_first_slot():
	# Grab the first available rucksack slot
	if rucksack_grid.get_child_count() > 0:
		rucksack_grid.get_child(0).grab_focus()

func _spawn_doll():
	
	if doll_scene:
		current_doll = doll_scene.instantiate()
		stats_section.add_child(current_doll)
		
		if player:
			current_doll.update_preview_visuals(player.equipment_slots)
			
			
func _despawn_doll():
	if current_doll:
		current_doll.queue_free()
		current_doll = null
