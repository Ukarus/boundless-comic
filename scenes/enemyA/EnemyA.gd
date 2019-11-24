extends KinematicBody2D
# Estados: Idle Caminar Ataque Ataque_Retraso Muerto
enum estados {IDLE, CAMINAR, ATAQUE, ATAQUE_RETRASO, MUERTO}
var estado = estados.IDLE

var mirar_izq = false
var ataque_retraso = false
var ataque_activo = true
var muerto = false

#Debemos sincronizar el ataque del golem con la animacion
var t_golpe = 0.2

var t_ataque = 0.0
export var r_ataque = 1.5 # retraso entre ataque y ataque

export var vida = 200
export var atq = 25

export var RANGO_ATAQUE = 160.0
export var RANGO_MOV = 1000.0
export var VEL_MOV = 150.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Idle")
	#add_to_group("Enemigo")
	#add_to_group("breakable")
	$BarraVida.max_value = vida
	$BarraVida.value = vida
	pass

func take_damage():
	var dmg = 50
	if muerto:
		return
	if not $BarraVida.visible:
		$BarraVida.show()
	vida -= dmg
	# Empujar personaje
	$BarraVida.value = vida
	if vida <= 0:
		$AnimationPlayer.play("Muerte")
		$BarraVida.hide()
		#$AreaAtaque.hide()
		var player = get_tree().get_nodes_in_group("Player")[0]
		if player:
			add_collision_exception_with(player)
		var enemigos = get_tree().get_nodes_in_group("Enemigo")
		for e in enemigos:
			add_collision_exception_with(e)
		remove_from_group("Enemigo")
		muerto = true
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
	#print("Distancia: " + str(dist_abs))
	var nuevo_mirar_izq = false
	#mirar hacia personaje
	if dist < 0:
		nuevo_mirar_izq = true
	else:
		nuevo_mirar_izq = false

	if nuevo_mirar_izq != mirar_izq:
		if nuevo_mirar_izq:
			$Sprite.scale = Vector2(1,1)
			$AreaAtaque.scale = Vector2(1,1)
		else:
			$Sprite.scale = Vector2(-1,1)
			$AreaAtaque.scale = Vector2(-1,1)
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
	pass

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
		if $AnimationPlayer.current_animation_position >= t_golpe:
			var cuerpos = $AreaAtaque.get_overlapping_bodies()
			for c in cuerpos:
				if ataque_activo:
					if c.is_in_group("Escudo"):
						#ejecutar sonido
						#bajar estamina
						#ejecutar_sonido()
						ataque_activo = false
						c.get_parent().golpe_escudo(atq+10)
			if ataque_activo:
				for c in cuerpos:
					if c.is_in_group("Aliado"):
						c.danio(atq)
						ataque_activo = false
						#ejecutar_sonido()
				
		pass
	elif estado == estados.ATAQUE_RETRASO:
		t_ataque  += delta
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
	pass # Replace with function body.

