extends KinematicBody2D

export (int) var run_speed = 400
export (int) var jump_speed = -800
export (int) var gravity = 1200
export (int) var life = 300
var velocity = Vector2()
var jumping = false
var attacks = ["attack1", "attack2", "attack3"]
var next_attack = 0
var checkpoint = null
onready var hitbox_degrees = $PlayerHitbox.rotation_degrees
signal update_life

func _ready():
	$AnimationPlayer.play("idle")
	add_to_group("Player")

func take_damage(dmg):
	self.life -= dmg
	emit_signal("update_life", self.life)

func get_input():
	velocity.x = 0
	var jump = Input.is_action_just_pressed("ui_up")
	
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
		$AnimationPlayer.stop()
		$AnimationPlayer.play("jumping")
	if Input.is_action_pressed("ui_right"):
		velocity.x += run_speed
		$Sprite.scale.x = 1
		#print($PlayerHitbox.rotation_degrees < 0, $PlayerHitbox.rotation_degrees)
		if $PlayerHitbox.rotation_degrees < 0:
			$PlayerHitbox.rotation_degrees *= -1
		$AttackHitbox.scale.x = 1
		if Input.is_action_pressed("ui_up") || jumping:
			$AnimationPlayer.play("jumping")
		if is_on_floor():
			$AnimationPlayer.play("running")
	if Input.is_action_pressed("ui_left"):
		velocity.x -= run_speed
		$Sprite.scale.x = -1
		print($PlayerHitbox.rotation_degrees > 0, $PlayerHitbox.rotation_degrees)
		#if $PlayerHitbox.rotation_degrees > 0:
		#$PlayerHitbox.rotation_degrees *= -1
		$AttackHitbox.scale.x = -1
		if Input.is_action_pressed("ui_up") || jumping:
			$AnimationPlayer.play("jumping")
		if is_on_floor():
			$AnimationPlayer.play("running")
	if Input.is_action_pressed("ui_down"):
		if is_on_floor():
			$AnimationPlayer.play("crouch")
	if Input.is_action_just_pressed("atacar"):
		$AnimationPlayer.play(attacks[next_attack])
		if (next_attack < attacks.size() - 1 ):
			next_attack += 1
		else:
			next_attack = 0
		#$AnimationPlayer.play("basic_punch")
	if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_down"):
		$AnimationPlayer.play("idle")
		
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_AttackHitbox_body_entered(body):
	if body.is_in_group("breakable"):
		body.take_damage(1)
	if body.is_in_group("Enemigo"):
		body.take_damage(30)
		