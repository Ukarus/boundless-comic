extends KinematicBody2D

export (int) var run_speed = 400
export (int) var jump_speed = -550
export (int) var gravity = 1200
export (int) var life = 300
export (PackedScene) var bomb

signal hit
signal hide_bomb
var velocity = Vector2()
var jumping = false
var screen_size
var can_grab_item = false
var has_item = false
var inventory = []

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimationPlayer.play("idle")

func can_grab_item():
	can_grab_item = true

func can_not_grab_item():
	can_grab_item = false

func get_input():
	velocity.x = 0
	var jump = Input.is_action_pressed("ui_up")
	
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	if Input.is_action_pressed("ui_right"):
		velocity.x += run_speed
		$Sprite.scale.x = 1
		$AnimationPlayer.play("running")
	if Input.is_action_pressed("ui_left"):
		velocity.x -= run_speed
		$Sprite.scale.x = -1
		$AnimationPlayer.play("running")

	if Input.is_action_pressed("grab_item"):
		if (can_grab_item):
			if !inventory.has(bomb): 
				inventory.append(bomb)
				#print(get_tree().get_root().get_node("Bomb"))
				get_parent().get_node("Bomb").queue_free()
				#get_node("/root/parent/Bomb").queue_free()
		else:
			print("can not grab item")
	if Input.is_action_just_pressed("attack"):
		$AnimationPlayer.play("attack1")
	
		
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_SwordHit_area_entered(body):
	print(body)
	if body.is_in_group("enemies"):
		body.get_parent().hurt(20)
	elif body.is_in_group("breakable"):
		body.take_damage()

func take_damage(damage):
	self.life -= damage

func _on_SwordHit_body_entered(body):
	if body.is_in_group("breakable"):
		body.get_parent().take_damage()
