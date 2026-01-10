extends Entity

signal inventory_changed(rucksack: Array[ItemData], equipment: Dictionary)

@onready var state_machine = $StateMachine
@onready var neck = $SpringArm3D/PivotPoint
@onready var camera = $SpringArm3D/PivotPoint/Camera3D
@onready var slected_char = $Rogue
@onready var right_hand = $Rogue/Rig_Medium/Skeleton3D/RightHand/RightHandWeapon
@onready var left_hand = $Rogue/Rig_Medium/Skeleton3D/LeftHand/LeftHandWeapon
@onready var springy = $SpringArm3D
@onready var searchy = $LockOnArea
@onready var searchy_shape = $LockOnArea/CollisionShape3D
@onready var inventory_ui = $InventoryUI

# TEST vars
@export var katana_test: ItemData
@export var club_test: ItemData
@export var wooden_shield_test: ItemData

# Constants
const SPEED = 7.0
const JUMP_VELOCITY = 6
const DODGE_TIME = 0.55
const FWD_DODGE_DIS = 10
const BWK_DODGE_DIS = -5
const LOOK_SENS = 2.5
const LIGHT_ATK_LUNG = 5
const HEAVY_ATK_LUNG = 7
const ANGLE_CONVERSION = 180
const LOCKED_H_OFFSET = 1.5
const OFFSET_SPEED = 4.0

# Variables for States to modify/read
var target_enemy: Entity = null
var equipped_right: Node3D = null
var equipped_left: Node3D = null
var ruck_sacked: Array[ItemData] = []
var equipment_slots = {
	"RIGHT_HAND": null,
	"LEFT_HAND": null
}

func _ready() -> void:
	# Initialize the State Machine FIRST so it's ready to receive items
	state_machine.init(self)
	
	add_item_to_ruck(katana_test)
	add_item_to_ruck(club_test)
	add_item_to_ruck(wooden_shield_test)

func _process(delta: float) -> void:
	_looking_process(delta)
	
	if anim_state:
		var current_node = anim_state.get_current_node()
		is_attacking = "Attack" in current_node

func _physics_process(delta: float) -> void:
	# Global hit detection
	check_weapon_hitbox()
	
	# Global UI Toggle
	if Input.is_action_just_released("inventory"):
		toggle_inventory()


func equip_from_inventory(index: int): 
	if index >= ruck_sacked.size(): return
	var new_data = ruck_sacked[index]
	var slot_key = "RIGHT_HAND" 
	if new_data.type == ItemData.SlotType.SHIELD:
		slot_key = "LEFT_HAND"
	
	var old_data = equipment_slots[slot_key]
	ruck_sacked.remove_at(index)
	equipment_slots[slot_key] = new_data
	
	if old_data:
		ruck_sacked.append(old_data)
	
	equip_from_data(new_data)
	inventory_changed.emit(ruck_sacked, equipment_slots)

func equip_from_data(data: ItemData):
	match data.type:
		ItemData.SlotType.ONE_HAND:
			_clear_slot("right")
			equipment_slots.RIGHT_HAND = data
			equipped_right = _spawn_model(data, right_hand)
			current_weapon = equipped_right
		ItemData.SlotType.SHIELD:
			_clear_slot("left")
			equipment_slots.LEFT_HAND = data
			equipped_left = _spawn_model(data, left_hand)

func _clear_slot(side: String):
	if side == "right" and equipped_right:
		equipped_right.queue_free()
		equipped_right = null	
		left_hand.transform = Transform3D.IDENTITY
	elif side == "left" and equipped_left:
		equipped_left.queue_free()
		equipped_left = null

func _spawn_model(data: ItemData, socket: Node3D) -> Node3D:
	if data.scene_to_spawn == null: return null
	var instance = data.scene_to_spawn.instantiate()
	if instance.has_method("apply_item_data"):
		instance.apply_item_data(data)	
	if instance is BaseWeapon:
		instance.owner_entity = self
	socket.add_child(instance)
	instance.transform = Transform3D.IDENTITY
	return instance

func add_item_to_ruck(data: ItemData):
	if data:
		ruck_sacked.append(data)
		inventory_changed.emit(ruck_sacked, equipment_slots)

func unequip_item(slot_key: String):
	var item_to_return = equipment_slots[slot_key]
	if item_to_return == null: return
	equipment_slots[slot_key] = null
	if slot_key == "RIGHT_HAND":
		_clear_slot("right")
		current_weapon = null
	elif slot_key == "LEFT_HAND":
		_clear_slot("left")
	add_item_to_ruck(item_to_return)

func toggle_inventory():
	inventory_ui.visible = !inventory_ui.visible
	if inventory_ui.visible:
		state_machine.change_to("Idle")
		inventory_changed.emit(ruck_sacked, equipment_slots)
		inventory_ui.focus_first_slot()

func _looking_process(delta):
	if is_locked_on and target_enemy:
		var target_pos = target_enemy.global_position + Vector3(0, 1.3, 0)
		var new_transform = springy.global_transform.looking_at(target_pos, Vector3.UP)
		springy.global_transform.basis = springy.global_transform.basis.slerp(new_transform.basis, delta * OFFSET_SPEED)
		neck.rotation.x = lerp_angle(neck.rotation.x, 0, delta * OFFSET_SPEED)
		camera.h_offset = lerp(camera.h_offset, LOCKED_H_OFFSET, delta * OFFSET_SPEED)
	else:
		var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		camera.h_offset = lerp(camera.h_offset, 0.0, delta * OFFSET_SPEED)
		if look_dir.length() > 0:
			springy.rotate_y(-look_dir.x * LOOK_SENS * delta)
			neck.rotate_x(-look_dir.y * LOOK_SENS * delta)
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func rotate_towards_target(target_pos: Vector3, delta: float, instant: bool = false):
	var dir_to_target = (target_pos - global_position).normalized()
	var target_angle = atan2(-dir_to_target.x, -dir_to_target.z) + deg_to_rad(ANGLE_CONVERSION)
	if instant:
		slected_char.rotation.y = target_angle
	else:
		slected_char.rotation.y = lerp_angle(slected_char.rotation.y, target_angle, delta * 20.0)
