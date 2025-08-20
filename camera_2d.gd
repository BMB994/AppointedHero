extends Camera2D

# Variables to control the camera's movement and zoom
@export var zoom_in_rate: float = 0.05
@export var scroll_speed: float = 10.0
var target_zoom: Vector2 = Vector2(1, 1)
var target_position: Vector2 = Vector2.ZERO

func _ready():
	var viewport_size = get_viewport_rect().size
	var center_position = viewport_size / 2
	target_position = center_position
	
# This function updates the camera's state every frame
func _process(delta: float) -> void:
	position = position.lerp(target_position, delta * scroll_speed)
	zoom = zoom.lerp(target_zoom, delta * 5)
