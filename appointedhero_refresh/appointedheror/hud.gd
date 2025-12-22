extends Control
@onready var health_bar = $Margin/VBoxContainer/HealthBar

func _ready():
	# Find the player and connect to their health signal
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(update_health_bar)
		# Set initial value
		update_health_bar(player.current_health, player.max_health)

func update_health_bar(current, max_val):
	# 1. Update the Width (The Upgrade Logic)
	# We use max_val to decide how wide the bar should be
	# Let's say 2 pixels per 1 HP point
	var target_width = max_val * 0.5
	health_bar.custom_minimum_size.x = target_width
	
	# 2. Update the Max Value (for the internal math)
	health_bar.max_value = max_val
	
	# 3. The "Tween" for taking damage
	# This makes the red bar slide down smoothly instead of teleporting
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
