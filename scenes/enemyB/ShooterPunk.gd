extends KinematicBody2D
# Estados: Idle Caminar Ataque Ataque_Retraso Muerto
enum estados {IDLE, CAMINAR, ATAQUE, ATAQUE_RETRASO, MUERTO}
var estado = estados.IDLE


var enemy = null
var mirar_izq = false
var ataque_retraso = false
var ataque_activo = true
var muerto = false
var player = null

#Debemos sincronizar el ataque con la animacion
var t_golpe = 0.1

var t_ataque = 0.0
export var r_ataque = 1.5 # retraso entre ataque y ataque
export var speed = Vector2(400.0, 500.0)

export var vida = 200
export var atq = 25

export var RANGO_ATAQUE = 450
export var RANGO_MOV = 1000.0
export var VEL_MOV = 150.0

var _velocity = Vector2.ZERO
const FLOOR_NORMAL = Vector2.UP
onready var health_bar = $BarraVida
onready var animation_player = $AnimationPlayer
onready var floor_detector_left = $FloorDetectorLeft
onready var floor_detector_right = $FloorDetectorRight

#CUSTOM SIGNALS
signal spawnBullet

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health_bar_life(vida)	

func take_damage(dmg):
	if muerto:
		return
	if not health_bar.visible:
		health_bar.show()
	vida -= dmg
	# Empujar personaje
	health_bar.value = vida
	if vida <= 0:
		health_bar.hide()
		animation_player.play("Death")


func _pensar():
	if not ataque_activo or ataque_retraso:
		return
	if enemy:
		# Si jugador se encuentra en rango
		var dist = enemy.global_position.x - global_position.x
		var dist_abs = global_position.distance_to(enemy.global_position)
		var nuevo_mirar_izq = false
		#mirar hacia personaje
		# si el enemigo esta a la izquierda
		if dist < 0:
			nuevo_mirar_izq = true
		# si el enemigo esta a la derecha
		else:
			nuevo_mirar_izq = false

		if nuevo_mirar_izq != mirar_izq:
			if nuevo_mirar_izq:
				$Sprite.scale = Vector2(1,1)
			else:
				$Sprite.scale = Vector2(-1,1)
		mirar_izq = nuevo_mirar_izq
		
		var isEdgeOnLeft = !floor_detector_left.is_colliding()
		var isEdgeOnRight = !floor_detector_right.is_colliding()
		
		if (self.is_on_edge()):
			if(dist_abs <= RANGO_ATAQUE):
				estado = estados.ATAQUE
				ataque_activo = true
				animation_player.play("Attack")
			elif (dist < 0 && isEdgeOnLeft):
				estado = estados.IDLE
				animation_player.play("Idle")
			elif(dist > 0 && isEdgeOnRight):
				estado = estados.IDLE
				animation_player.play("Idle")
			else:
				estado = estados.CAMINAR
				animation_player.play("Run")
		else:
			if(dist_abs <= RANGO_ATAQUE):
				print("on attack range")
				estado = estados.ATAQUE
				ataque_activo = true
				animation_player.play("Attack")
			elif(dist_abs <= RANGO_MOV):
				estado = estados.CAMINAR
				animation_player.play("Run")
			else:
				estado = estados.IDLE
				animation_player.play("Idle")

func shoot():
	var bulletVector = $ShootPointL.get_global_position() if mirar_izq else $ShootPointR.get_global_position()
	
	emit_signal("spawnBullet", {
		"direction": "left" if mirar_izq else "right",
		"bulletPosition": bulletVector,
		"bulletDirection": Vector2(-1, 0) if mirar_izq else Vector2(1,0)
	})		


func _physics_process(delta):
	if muerto:
		return

	_pensar()
	
	if estado == estados.IDLE:
		pass
	elif estado == estados.CAMINAR:
		_velocity = calculate_move_velocity(_velocity, mirar_izq)
		# We only update the y value of _velocity as we want to handle the horizontal movement ourselves.
		_velocity.y = move_and_slide(_velocity, Vector2.ZERO, false, 4, 0.785398, true).y
	elif estado == estados.ATAQUE:
		if animation_player.current_animation_position >= t_golpe and ataque_activo: 
			shoot()
			ataque_activo = false
	elif estado == estados.ATAQUE_RETRASO:
		t_ataque += delta
		if t_ataque >= r_ataque:
			t_ataque = 0.0
			ataque_activo = true
			ataque_retraso = false
			estado = estados.IDLE

func calculate_move_velocity(
		linear_velocity,
		mirar_izq
	):
		
	var velocity = linear_velocity
	velocity.y = 9.8
	if mirar_izq:
		velocity.x = -1.0
	else:
		velocity.x = 1.0
	velocity = velocity * VEL_MOV
	
	return velocity
	
func is_on_edge():
	if not floor_detector_left.is_colliding():
		return true
	if not floor_detector_right.is_colliding():
		return true
	return false

func set_health_bar_life(life):
	health_bar.max_value = vida
	health_bar.value = vida

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		estado = estados.ATAQUE_RETRASO
		ataque_retraso = true
		animation_player.play("Idle")


func _on_Area2D_body_entered(body):
	enemy = body


func _on_Area2D_body_exited(body):
	enemy = null
