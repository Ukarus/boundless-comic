extends KinematicBody2D

export (int) var dist_min
export (int) var enemy_velocity
export (int) var gravity
export (int) var damage = 30
var screen_size
onready var player = get_node("/root/Node2D/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	var velocity = Vector2()
	var dir = player.position - self.position
	
	if (sqrt(dir.x * dir.x + dir.y * dir.y) <= dist_min):
		if (dir.x < 0):
			velocity.x -= 1
		else:
			velocity.x += 1
		velocity.x *= enemy_velocity
	velocity.y += gravity * delta
	move_and_slide(velocity, Vector2(0, -1))

func _on_Area2D_body_entered(body):
	if body.has_method("get_input"):
		body.life -= 30
