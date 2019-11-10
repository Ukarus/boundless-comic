extends Path2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var ruta = get_node("PathFollow2D")
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
func _process(delta):
	ruta.set_offset(ruta.get_offset() + 150 * delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
