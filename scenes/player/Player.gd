extends KinematicBody2D

export (int) var run_speed = 100
export (int) var jump_speed = -550
export (int) var gravity = 1200
export (int) var life = 300

signal hit
var velocity = Vector2()
var jumping = false
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func get_input():
	velocity.x = 0
	var jump = Input.is_action_pressed("ui_up")
	
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	if Input.is_action_pressed("ui_right"):
		velocity.x += run_speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= run_speed
		
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	velocity = move_and_slide(velocity, Vector2(0, -1))