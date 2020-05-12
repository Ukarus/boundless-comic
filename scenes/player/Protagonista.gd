extends KinematicBody2D
export (int) var gravity = 1200
export (int) var life = 300
export var speed: = Vector2(300.0, 1000.0)
const FLOOR_DETECT_DISTANCE = 40.0
const FLOOR_NORMAL = Vector2.UP
var _velocity: = Vector2.ZERO
var jumping = false
var attacks = ["attack1", "attack2", "attack3"]
var next_attack = 0
var checkpoint = null
onready var sprite = $Sprite
onready var hitbox_degrees = $PlayerHitbox.rotation_degrees
onready var animation_player = $AnimationPlayer
signal update_life

func _ready():
	$AnimationPlayer.play("idle")
	add_to_group("Player")

func take_damage(dmg):
	self.life -= dmg
	emit_signal("update_life", self.life)

"""
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
	if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_down"):
		$AnimationPlayer.play("idle")
		
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	velocity = move_and_slide(velocity, Vector2(0, -1))
"""

func _physics_process(delta :float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("ui_up") and _velocity.y < 0.0
	var direction: = self.get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if direction.y == 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, true, 4,  0.9, false
	)
	
	self.flip_sprite(direction)
	
	var is_attacking = Input.is_action_just_pressed("attack")

	var animation = self.get_new_animation(is_attacking)
	if animation != animation_player.current_animation:
		animation_player.play(animation)
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("ui_right")	- Input.get_action_strength("ui_left"), 
		-1.0 if Input.is_action_just_pressed("ui_up") and is_on_floor() else 1.0
	)

func flip_sprite(direction: Vector2) -> void:
	if direction.x != 0:
		sprite.scale.x = direction.x

func calculate_move_velocity(
		linear_velocity: Vector2, 
		direction: Vector2, 
		speed: Vector2,
		is_jump_interrupted: bool
	) ->  Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		out.y = speed.y * direction.y
	if is_jump_interrupted:
		out.y = 0.0
	return out

func get_new_animation(is_attacking = false) -> String:
	var animation_new = ""
	if is_on_floor():
		animation_new = "running" if _velocity.x != 0 else "idle"
	else:
		if _velocity.y < 0:
			animation_new = "jumping"
	if is_attacking:
		animation_new = "attack1"
	return animation_new

func _on_AttackHitbox_body_entered(body):
	if body.is_in_group("breakable"):
		body.take_damage(1)
	if body.is_in_group("Enemigo"):
		body.take_damage(30)
		