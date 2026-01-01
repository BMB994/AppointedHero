extends CharacterBody3D

@onready var preview_right_hand = $Rogue/Rig_Medium/Skeleton3D/RightHand/RightHandWeapon
@onready var preview_left_hand = $Rogue/Rig_Medium/Skeleton3D/LeftHand/LeftHandWeapon

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Connect signal so it updates while the menu is open
		player.inventory_changed.connect(_on_inventory_changed)
		# Initial sync for when it first spawns
		update_preview_visuals(player.equipment_slots)

func _on_inventory_changed(_rucksack, equipment: Dictionary):
	update_preview_visuals(equipment)

func update_preview_visuals(equipment: Dictionary):
	# Safety check for @onready variables
	if not preview_right_hand or not preview_left_hand: return
	
	# 1. Clear current preview items
	for child in preview_right_hand.get_children(): child.queue_free()
	for child in preview_left_hand.get_children(): child.queue_free()
	
	# 2. Spawn preview items
	if equipment.get("RIGHT_HAND"):
		_spawn_to_preview(equipment["RIGHT_HAND"], preview_right_hand)
	if equipment.get("LEFT_HAND"):
		_spawn_to_preview(equipment["LEFT_HAND"], preview_left_hand)

func _spawn_to_preview(data: ItemData, socket: Node3D):
	if data and data.scene_to_spawn:
		var instance = data.scene_to_spawn.instantiate()
		socket.add_child(instance)
		instance.transform = Transform3D.IDENTITY
