extends KinematicBody2D

export (int) var WALK_SPEED = 2000
enum states {CHASE, IDLE, ATTACK}

const ATTACK_DAMAGE = 30
var attacks = ["attack1", "attack2"]
var player = null
var velocity = Vector2.ZERO
var state = states.IDLE
var currentAnimation = "idle"
var canAttack = true
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var attackTimer = $AttackTimer
onready var hurtBox = $HurtBox


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target
	match state:
		states.CHASE:
			if player != null:
				target = player.position
				velocity = (target - position).normalized() * WALK_SPEED * delta
				currentAnimation = "walk"
		states.IDLE:
			currentAnimation = "idle"
		states.ATTACK:
			velocity = Vector2.ZERO
			if canAttack:
				currentAnimation = "attack1"
				attackTimer.start()
				canAttack = false
		
	flip_sprite()
	animationPlayer.play(currentAnimation)
	velocity = move_and_slide(velocity)

func flip_sprite():
	if velocity.x > 0:
		sprite.scale.x = 1
		hurtBox.scale.x = 1
	elif velocity.x < 0:
		sprite.scale.x = -1
		hurtBox.scale.x = -1

func _on_DetectRadius_body_entered(body):
	player = body
	state = states.CHASE


func _on_DetectRadius_body_exited(_body):
	player = null
	state = states.IDLE


func _on_AttackRadius_body_entered(body):
	state = states.ATTACK


func _on_AttackTimer_timeout():
	canAttack = true


func _on_AttackRadius_body_exited(_body):
	state = states.CHASE


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack1":
		currentAnimation = "idle"


func _on_HurtBox_body_entered(body):
	body.take_damage(ATTACK_DAMAGE)
