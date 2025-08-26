extends Camera2D

# Variables to control the camera's movement and zoom
@export var zoom_in_rate: float = 0.05
@export var scroll_speed: float = 10.0
var target_zoom: Vector2 = Vector2(1, 1)
var target_position: Vector2 = Vector2.ZERO
@onready var fade_screen = $CanvasLayer/ColorRect

func _ready():
	#var viewport_size = get_viewport_rect().size
	#var center_position = viewport_size / 2
	#target_position = center_position
	fade_screen.hide()

	
# This function updates the camera's state every frame
func _process(delta: float) -> void:
	#position = position.lerp(target_position, delta * scroll_speed)
	#zoom = zoom.lerp(target_zoom, delta * 5)
	pass

func set_middle():
	
	var fade_tween = create_tween()
	fade_screen.show()
	fade_screen.modulate = Color(0, 0, 0, 1)
	fade_tween.tween_property(fade_screen, "modulate", Color(0, 0, 0, 1), 0.5)
	
	await fade_tween.finished
	
	self.zoom = Vector2(1.0, 1.0)
	self.position = get_viewport_rect().size / 2
	
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(fade_screen, "modulate", Color(0, 0, 0, 0), 0.5)
	
	await fade_in_tween.finished

	fade_screen.hide()

func set_main_screen(pos, zoom_level):
	position = pos
	var tween = create_tween()
	tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), 0)
