extends KinematicBody2D

export (int) var life = 200
enum states {PATROL, CHASE, ATTACK, DEAD}
var state = states.PATROL

#for setting animations
var anim_state
var run_speed = 30
var attacks = ["attack1", "attack2"]

export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0

var player = null
var velocity = Vector2()

func _ready():
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
	#anim_state = $AnimationTree.get("parameters/StateMachine/playback")
	#print(anim_state)
	$AnimationPlayer.play("idle")
	#anim_state.travel("idle")

func choose_action():
	velocity = Vector2()
	#var current = anim_state.get_current_node()
	
	#if current in attacks:
		#return
	
	if life <= 0:
		state = states.DEAD
		
	var target
	match state:
		states.DEAD:
			set_physics_process(false)
			queue_free()
			
		states.PATROL:
			if !patrol_path:
				return
			target = patrol_points[patrol_index]
			if position.distance_to(target) < 1:
				patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
				target = patrol_points[patrol_index]
			velocity = (target - position).normalized() * run_speed
		
		states.CHASE:
			target = player.position
			velocity = (target - position).normalized() * run_speed
		
		states.ATTACK:
			if player:
				target = player.position
				if target.x > position.x:
					$Sprite.scale.x = 1
				elif target.x < position.x:
					$Sprite.scale.x = -1
				$AnimationPlayer.play("attack1")
				#anim_state.travel("attack1")

func _physics_process(delta):
	choose_action()
	if velocity.x > 0:
		$Sprite.scale.x = 1
	elif velocity.x < 0:
		$Sprite.scale.x = -1
		
	if velocity.length() > 0:
		#anim_state.travel("running")
		$AnimationPlayer.play("running")
	
	velocity = move_and_slide(velocity)

func _on_DetectRadius_body_entered(body):
	if body.is_in_group("player"):
		state = states.CHASE
		player = body

func _on_DetectRadius_body_exited(body):
	if body.is_in_group("player"):
		state = states.PATROL
		player = null


func _on_AttackRadius_body_entered(body):
	state = states.ATTACK


func _on_AttackRadius_body_exited(body):
	state = states.CHASE
	
func hurt(damage):
	self.life -= damage
	print(self.life)
	


func _on_AxeHit_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(30)
