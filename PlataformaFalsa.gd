extends Area2D

# Declare member variables here. Examples:
var toco = 0
# var b = "text"
var velocity = Vector2()
export (int) var gravedad = 1200
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if toco == 1:
		velocity.y += gravedad * delta
		self.get_node("FisicaPlataforma").move_and_slide(velocity, Vector2(0, -1))
		

func _on_PlataformaFalsa_body_entered(body):
	if body.is_in_group("jugador"):
		toco = 1