extends TextureButton

@onready var stack_count = $StackCount
@export var placeholder_texture: Texture2D

var current_data: ItemData

func display(data: ItemData, count: int = 1):
	current_data = data
	
	if data:
		texture_normal = data.icon
		
		# Show stack count if greater than 1
		if count > 1:
			stack_count.text = str(count)
			stack_count.show()
		else:
			stack_count.hide()
	else:
		# Show blank
		texture_normal = placeholder_texture
		modulate = Color(1, 1, 1, 0.3)
		stack_count.hide()
