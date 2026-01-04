extends Resource
class_name ItemData

enum SlotType { ONE_HAND, SHIELD }

@export var type: SlotType = SlotType.ONE_HAND
@export var item_id: String = ""
@export var display_name: String = "New Item"
@export var icon: Texture2D
@export var scene_to_spawn: PackedScene
@export_multiline var description: String = ""
@export_group("Stats")
@export var light_damage: float = 0.0
@export var heavy_damage: float = 0.0
@export var blocking_power: float = 0.0
@export var weight: float = 1.0
