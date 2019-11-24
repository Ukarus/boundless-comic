extends KinematicBody2D

export (int) var run_speed = 400
export (int) var jump_speed = -800
export (int) var gravity = 1200
export (int) var life = 300
var velocity = Vector2()
var jumping = false

func _ready():
	$AnimationPlayer.play("idle")
	add_to_group("Player")

func get_input():
	velocity.x = 0
	var jump = Input.is_action_just_pressed("ui_up")
	
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
		$AnimationPlayer.play("jumping")
	if Input.is_action_pressed("ui_right"):
		velocity.x += run_speed
		$Sprite.scale.x = 1
		$AnimationPlayer.play("running")
	if Input.is_action_pressed("ui_left"):
		velocity.x -= run_speed
		$Sprite.scale.x = -1
		$AnimationPlayer.play("running")
	if Input.is_action_pressed("ui_down"):
		$AnimationPlayer.play("crouch")
	if Input.is_action_just_pressed("atacar"):
		$AnimationPlayer.play("basic_punch")
	
	if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_down"):
		$AnimationPlayer.play("idle")
		
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_AttackHitbox_body_entered(body):
	print(body, body.is_in_group("breakable"))
	if body.is_in_group("breakable"):
		body.take_damage()
