extends CanvasLayer


func update_dead_count(text):
	$DeadCount.text = "Dead Enemies: " + str(text)
	$DeadCount.show()

func update_soul_count(text):
	$SoulCount.text = "Souls Gathered: " + str(text)
	$SoulCount.show()
	
func update_level(text):
	$Level.text = "Level: " + str(text)
	$Level.show()
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
