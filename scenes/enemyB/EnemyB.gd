extends KinematicBody2D
# Estados: Idle Caminar Ataque Ataque_Retraso Muerto
enum estados {IDLE, CAMINAR, ATAQUE, ATAQUE_RETRASO, MUERTO}
var estado = estados.IDLE

var mirar_izq = false
var ataque_retraso = false
var ataque_activo = true
var muerto = false
var player = null

#Debemos sincronizar el ataque con la animacion
var t_golpe = 0.1

var t_ataque = 0.0
export var r_ataque = 1.5 # retraso entre ataque y ataque

export var vida = 200
export var atq = 25

export var RANGO_ATAQUE = 450
export var RANGO_MOV = 1000.0
export var VEL_MOV = 150.0

onready var bullet = preload("res://scenes/enemyB/LaserBullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Idle")
	$BarraVida.max_value = vida
	$BarraVida.value = vida
	pass

func take_damage(dmg):
	if muerto:
		return
	if not $BarraVida.visible:
		$BarraVida.show()
	vida -= dmg
	# Empujar personaje
	$BarraVida.value = vida
	if vida <= 0:
		$AnimationPlayer.play("Death")
		$BarraVida.hide()
		queue_free()

func _decidir_ataque():
	pass

func _pensar():
	if not ataque_activo or ataque_retraso:
		return
	var enemigo = get_tree().get_nodes_in_group("Player")[0]
	if not enemigo:
		pass
	
	# Si jugador se encuentra en rango
	var dist = enemigo.global_position.x - global_position.x
	var dist_abs = global_position.distance_to(enemigo.global_position)
	var nuevo_mirar_izq = false
	#mirar hacia personaje
	if dist < 0:
		nuevo_mirar_izq = true
	else:
		nuevo_mirar_izq = false

	if nuevo_mirar_izq != mirar_izq:
		if nuevo_mirar_izq:
			$Sprite.scale = Vector2(1,1)
		else:
			$Sprite.scale = Vector2(-1,1)
	mirar_izq = nuevo_mirar_izq
	if(dist_abs <= RANGO_ATAQUE):
		estado = estados.ATAQUE
		ataque_activo = true
		$AnimationPlayer.play("Attack")
		
	# Sino
	elif(dist_abs <= RANGO_MOV):
		# Saltar si jugador se encuentra mas arriba
		## Caminar hacia personaje
		estado = estados.CAMINAR
		$AnimationPlayer.play("Run")
	else:
		estado = estados.IDLE
		$AnimationPlayer.play("Idle")
		
func shoot():
	var B = bullet.instance()
	get_tree().get_root().add_child(B)
	if mirar_izq:
		B.set_global_position($ShootPointL.get_global_position())
		B.dir = Vector2(-1,0)
	else:
		B.set_global_position($ShootPointR.get_global_position())
		B.dir = Vector2(1,0)

func _physics_process(delta):
	if muerto:
		return

	_pensar()
	if estado == estados.IDLE:
		pass
	elif estado == estados.CAMINAR:
		if mirar_izq:
			move_and_slide(Vector2(-1.0,9.8)*VEL_MOV, Vector2( 0, 0 ), false, 4,0.785398,true)
		else:
			move_and_slide(Vector2(1.0,9.8)*VEL_MOV, Vector2( 0, 0 ), false, 4,0.785398,true)
	elif estado == estados.ATAQUE:
		if $AnimationPlayer.current_animation_position >= t_golpe and ataque_activo: 
			shoot()
			ataque_activo = false
		pass
	elif estado == estados.ATAQUE_RETRASO:
		t_ataque += delta
		if t_ataque >= r_ataque:
			t_ataque = 0.0
			ataque_activo = true
			ataque_retraso = false
			estado = estados.IDLE
		pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		estado = estados.ATAQUE_RETRASO
		ataque_retraso = true
		$AnimationPlayer.play("Idle")

func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player"):
		pass

func _on_AreaAtaque_body_entered(body):
	pass # Replace with function body.
