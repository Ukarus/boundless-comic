extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func update_life(life):
	$HBoxContainer/Bars/LifeBar/Gauge.value = life
	$HBoxContainer/Bars/LifeBar/Count/Background/Number.text = life as String

func set_max_life(life):
	$HBoxContainer/Bars/LifeBar/Gauge.max_value = life

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
