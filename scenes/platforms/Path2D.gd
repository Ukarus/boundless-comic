extends Path2D

export (int) var speed

onready var ruta = get_node("PathFollow2D")
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
func _process(delta):
	ruta.set_offset(ruta.get_offset() + speed * delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
