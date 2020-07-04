extends KinematicBody2D
export (int) var gravity = 1200
export (int) var life = 300
export var speed: = Vector2(300.0, 1000.0)
const FLOOR_DETECT_DISTANCE = 40.0
const FLOOR_NORMAL = Vector2.UP
var _velocity: = Vector2.ZERO
var attacks = ["attack1", "attack2", "attack3"]
var next_attack = 0
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
signal update_life

func take_damage(dmg):
	self.life -= dmg
	emit_signal("update_life", self.life)

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
	var is_crouching = Input.is_action_pressed("ui_down")

	var animation = self.get_new_animation(is_attacking, is_crouching)
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

func get_new_animation(is_attacking = false, is_crouching = false) -> String:
	var animation_new = ""
	if is_on_floor():
		if _velocity.x != 0:
			animation_new = "running"
		elif is_crouching:
			animation_new = "crouch"
		else:
			animation_new = "idle"
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
		
