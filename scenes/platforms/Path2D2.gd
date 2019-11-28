extends Path2D

export (int) var speed

onready var ruta = $PathFollow2D
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)


func _physics_process(delta):
	ruta.set_offset(ruta.get_offset() + speed * delta)