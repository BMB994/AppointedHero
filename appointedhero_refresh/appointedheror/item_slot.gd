extends TextureButton
class_name ItemSlot

@onready var stack_count = $StackCount
@export var placeholder_texture: Texture2D
@export var slot_name: String = "Rucksack"

var current_data: ItemData

func display(data: ItemData, count: int = 1):
	current_data = data
	
	if data:
		texture_normal = data.icon
		self_modulate = Color.WHITE
		# Show stack count if greater than 1
		if count > 1:
			stack_count.text = str(count)
			stack_count.show()
		else:
			stack_count.hide()
	else:
		# Show blank
		texture_normal = placeholder_texture
		self_modulate = Color(0.3, 0.3, 0.3, 0.5)
		stack_count.hide()
