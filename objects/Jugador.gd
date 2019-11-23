extends KinematicBody2D

#var sonidos_ataque = ["Audio/Corte_001.ogg","Audio/Corte_002.ogg","Audio/Corte_003.ogg","Audio/Corte_004.ogg"]
#var sonidos_golpe = ["Impacto golpe físico_001.ogg","Impacto golpe físico_002.ogg","Impacto golpe físico_003.ogg","Impacto golpe físico_004.ogg"]

const GRAVEDAD = Vector2(0.0, 1800.0)
const NORMAL_PISO = Vector2(0, -1)
const DETENER_DIAGONAL = 50.0
const MIN_TIEMPO_ENAIRE = 0.1
const VEL_CAMINAR = 500.0
const VEL_CORRER = 650.0 # pixels/sec
const VEL_ESCUDO = 100.0
const VEL_SALTAR = 1000.0
const VEL_CAMBIO_DIR = 10.0
const VEL_CAJA = -16.0

var vel_linear = Vector2()
var tiempo_enaire = 0 #
var en_piso = false
var atacando = false
var escudo_roto = false
var caminar = false
var debug_escudo = false
var VELOCIDAD_ESTAMINA = 15 # por segundo?
# Retraso de ataque
var RETRASO_ATAQUE = 0.3
var ataque_tiempo = 1e20

var combate = false
var tiempo_combate = 0.0
var T_MAX_COMBATE = 2.0 #maximo dos segundos en combate

var bloquear_controles = false

var anim_escudo = false
var sentado = false

var anim=""
var nueva_anim = ""
var anim_ataque = "Ataque_1"

var aterrizar = false
var vel_caida = 800.0

#Guardar sprite aqui para acceso rápido (cambiaremos la escala frecuentemente)
onready var sprite = $Sprite
onready var area_ataque = $AreaAtaque
onready var escudo = $Escudo

# Conectar con UI
#onready var BarraVida = get_node("../Canvas/UI/BarraVida")
#onready var BarraEstamina = get_node("../Canvas/UI/BarraEstamina")
#onready var PocionesUI = get_node("../Canvas/UI/Pociones/Texto")
#onready var d_anim = preload("res://Objetos/DashAnim.tscn")
#var Danim = null
#onready var g_anim = preload("res://Objetos/GolpeEnemigo.tscn")
#var GolpeAnim = null
#onready var ge_anim = preload("res://Objetos/GolpeEscudo.tscn")

export var vida = 100
export var estamina = 100

## sistema dash
var cont_dash = 0 # apretar dos veces boton para hacer dash
var tiempo_dash = 0 # corre desde max_t_dash hasta 0
var MAX_T_DASH = 0.3 #retraso entre botones
var duracion_dash = 0
var DURACION_DASH = 0.25 #duracion de velocidad
var IMPULSO_DASH = 1200.0
var dash = false    # Iniciar dash
var dash_izq = false #Necesitamos que el dash sea hacia el mismo lado
var dash_bloq_aire = false #Bloquear dash en aire

var en_agua = false
var aire_full = true
var max_aire = 100
var aire = 100
var cont_ahogamiento = 1.0
var DANIO_AGUA = 10.0
var VEL_DANIO_AGUA = 1.0
var VEL_REC_AIRE = 25.0
var VEL_PER_AIRE = 10.0
onready var barra_aire = $BarraAire

onready var Sprite_Scale = $Sprite.scale.x

# Hablar con NPC
var NPC_ACCION = null

func set_npc(npc):
    NPC_ACCION = npc
func exit_npc():
    NPC_ACCION = null

func _disable_collision_cajas():
    for c in get_tree().get_nodes_in_group("Caja"):
        $Escudo.add_collision_exception_with(c)

func entrar_agua():
    en_agua = true
    barra_aire.show()

func salir_agua():
    en_agua = false
    
func _ready():
    anim_escudo = true
    ##Actualizar variables 
    #vida = VariablesJugador.vida
    #estamina = VariablesJugador.estamina
    #anim_escudo = VariablesJugador.escudo
    #BarraVida.max_value = VariablesJugador.max_vida
    #BarraEstamina.max_value = VariablesJugador.max_estamina
    #BarraVida.value = vida
    #BarraEstamina.value = estamina
    ##Actualizar marcador en canvas
    #PocionesUI.text = String(VariablesJugador.pociones)
    
    add_to_group("Jugador")

    if anim_escudo:
        if sentado:
            $AnimationPlayer.play("Sentarse")
            anim = "Sentarse"
            nueva_anim = "Sentarse"
        else:
            $AnimationPlayer.play("Idle_Escudo")
            anim = "Idle_Escudo"
            nueva_anim = "Idle_Escudo"
    else:
        $AnimationPlayer.play("Idle")
        anim = "Idle"
        nueva_anim = "Idle"
    $Escudo.add_to_group("Escudo")
    add_collision_exception_with($Escudo)
    #_disable_collision_cajas()
    

func reset(p_r):
    global_position = p_r.global_position

func accion():
    if NPC_ACCION:
        NPC_ACCION.accion()
    elif bloquear_controles:
        get_parent().accion()
    pass

func _unhandled_key_input(event):
    if Input.is_action_pressed("accion"):
        accion()
    elif Input.is_action_just_pressed("ui_right"):
        if caminar:
            return
        if cont_dash == 0:
            cont_dash += 1
            dash_izq = false
            tiempo_dash = MAX_T_DASH
        elif cont_dash == 1 and not dash_izq:
            if tiempo_dash > 0:# and en_piso:
                duracion_dash = 0
                dash = true
                sprite_dash()
        elif cont_dash == 1:
            dash_izq = false
        pass
    elif Input.is_action_just_pressed("ui_left"):
        if caminar:
            return
        if cont_dash == 0:
            cont_dash += 1
            dash_izq = true
            tiempo_dash = MAX_T_DASH
        elif cont_dash == 1 and dash_izq:
            if tiempo_dash > 0:# and en_piso:
                duracion_dash = 0
                dash = true
                sprite_dash()
        elif cont_dash == 1:
            dash_izq = true
        pass
    ## Utilizar pociones?
    #elif Input.is_action_just_pressed("pocion"):
    #   usar_pocion()
    #   pass
    pass

#func usar_pocion():
#   if VariablesJugador.pociones == 0:
#       #Sonido de error?
#       return
#   vida += VariablesJugador.potencia_pocion
#   VariablesJugador.pociones -= 1
#   VariablesJugador.vida = vida
#   BarraVida.value = vida
    #Actualizar marcador en canvas
#   PocionesUI.text = String(VariablesJugador.pociones)
#   pass

func danio(dmg):
    vida -= dmg
    #animacion de golpe
    #GolpeAnim = g_anim.instance()
    #get_tree().get_root().add_child(GolpeAnim)
    #GolpeAnim.global_position.y = self.global_position.y + randi()%60-30
    #GolpeAnim.global_position.x = self.global_position.x + randi()%20-10
    #GolpeAnim.global_rotation = randf()*365
    #GolpeAnim.scale = Vector2(randf()*1.5+0.5,randf()*1.5+0.5)
    
    if vida <= 0:
        vida = 0
        #VariablesJugador.vida = VariablesJugador.max_vida
        #VariablesJugador.estamina = VariablesJugador.max_estamina
        #vida = VariablesJugador.max_vida
        #estamina = VariablesJugador.max_estamina
        #reiniciar
        #VariablesJugador.reiniciar()
    #VariablesJugador.vida = vida
    #BarraVida.value = vida

func golpe_escudo(dmg):
    #animacion de golpe en escudo
    #var GolpeEscudo = ge_anim.instance()
    #get_tree().get_root().add_child(GolpeEscudo)
    #GolpeEscudo.global_position.y = self.global_position.y + randi()%20-10
    #if $Sprite.scale.x > 0.0:
    #   GolpeEscudo.global_position.x = self.global_position.x + randi()%5+50
    #else:
    #   GolpeEscudo.global_position.x = self.global_position.x + randi()%5-50
    #GolpeEscudo.global_rotation = randf()*365
    #GolpeEscudo.scale = Vector2(randf()*1.0+0.5,randf()*1.0+0.5)
    # Reducir estamina
    estamina -= dmg
    if estamina < 0:
        #se debe esperar a que estamina vuelva al 100%
        estamina = 0
        escudo_roto = true
        #BarraEstamina.roto()
    #VariablesJugador.estamina = estamina
    #BarraEstamina.value = estamina
    
func girar_izq(bul):
    if bul:
        $Sprite.scale.x = -1*Sprite_Scale
        $AreaAtaque.scale = Vector2(-1,1)
        $Escudo.scale = Vector2(-1,1)
    else:
        $Sprite.scale.x = Sprite_Scale
        $AreaAtaque.scale = Vector2(1,1)
        $Escudo.scale = Vector2(1,1)

func audio_ataque():
    #seleccionar sonido al azar
    #var r = sonidos_ataque[randi() % sonidos_ataque.size()]
    #$Sonido.stream = load("res://"+r)
    #$Sonido.play()
    pass
    
func audio_golpe():
    #seleccionar sonido al azar
    #var r = sonidos_golpe[randi() % sonidos_golpe.size()]
    #$Sonido.stream = load("res://Audio/"+r)
    #$Sonido.play()
    pass
    
func audio_dash():
    #$Sonido.stream = load("res://Audio/Dash!_002.ogg")
    #$Sonido.play()
    pass
    
func sprite_dash():
    #Danim = d_anim.instance()
    #get_tree().get_root().add_child(Danim)
    #Danim.global_position = self.global_position
    #if dash_izq:
    #   Danim.scale.x = -1
    pass
    
func _process(delta):
    if aire_full and not en_agua:
        return
    
    if en_agua:
        aire_full = false
        aire -= VEL_PER_AIRE*delta
        if aire <= 0:
            aire = 0
            cont_ahogamiento -= delta
            if cont_ahogamiento <= 0:
                danio(DANIO_AGUA)
                cont_ahogamiento = VEL_DANIO_AGUA
    else:
        aire += VEL_REC_AIRE*delta
    
    if aire >= max_aire:
        aire = max_aire
        aire_full = true
        barra_aire.hide()
    
    #actulizar barra
    barra_aire.value = aire

func _physics_process(delta):
    #increment counters
    tiempo_enaire += delta
    #shoot_time += delta
    
    var atacar = Input.is_action_pressed("atacar")
    var defensa = Input.is_action_pressed("defensa")
    var mover_izq = Input.is_action_pressed("ui_left")
    var mover_der = Input.is_action_pressed("ui_right")
    var saltar = Input.is_action_pressed("ui_up")
    
    if caminar:
        saltar = false
        defensa = false
        atacar = false
    
    #ESCUDO ROTO
    if escudo_roto:# or not VariablesJugador.escudo:
        defensa = false
    elif defensa:
        saltar = false
        
    #recuperar estamina
    if estamina < 100:
        estamina += VELOCIDAD_ESTAMINA * delta
        if estamina > 100:
            estamina = 100
            if escudo_roto:
                escudo_roto = false
                #BarraEstamina.normal()
        #VariablesJugador.estamina = estamina
        #BarraEstamina.value = estamina
    
    ### MOVEMENT ###
    # Aplicar gravedad
    vel_linear += delta * GRAVEDAD
    # Mover y deslizar
    vel_linear = move_and_slide(vel_linear+get_floor_velocity()/40,NORMAL_PISO, DETENER_DIAGONAL, 4,0.785395,false)
    
    # detectar piso
    if is_on_floor():
        if aterrizar:
            $AterrizarAnim/AnimationPlayer.play("Aterrizar")
            aterrizar = false
        tiempo_enaire = 0

    en_piso = tiempo_enaire < MIN_TIEMPO_ENAIRE
    if not en_piso and vel_linear.y > vel_caida:
        aterrizar = true
    
    ### CONTROL ###
    # Movimiento horizontal
    var vel_objetivo = 0.0
    if mover_izq:
        vel_objetivo += -1.0
    if mover_der:
        vel_objetivo +=  1.0
    
    if defensa and en_piso:
        vel_objetivo *= VEL_ESCUDO
        if mover_izq and vel_linear.x == 0:
            vel_linear.x -= VEL_ESCUDO/2
        elif mover_der and vel_linear.x == 0:
            vel_linear.x += VEL_ESCUDO/2
    else:
        if caminar:
            vel_objetivo *= VEL_CAMINAR
        else:
            vel_objetivo *= VEL_CORRER
    
    # DASH
    if dash:
        audio_dash()
        if dash_izq:
            vel_objetivo -= IMPULSO_DASH
            cont_dash = 0
        else:
            vel_objetivo += IMPULSO_DASH
            cont_dash = 0
        duracion_dash += delta
        if duracion_dash >= DURACION_DASH:
            dash = false
        if defensa:
            vel_objetivo /= 3
    if tiempo_dash > 0:
        tiempo_dash -= delta
        if tiempo_dash <= 0:
            cont_dash = 0
        
    vel_linear.x = lerp(vel_linear.x, vel_objetivo, 0.1)

    # add some sliding friction 
    if en_piso and vel_objetivo == 0:
        # 0.6 and lower quickly stops the sliding.
        # 0.7 and higher slows it but does not stop.
        vel_linear.x=0.6*vel_linear.x
    # Saltar
    if en_piso and saltar:
        vel_linear.y = -VEL_SALTAR
        #$sound_jump.play()
    
    # DEFENSA #
        
    if defensa && $Escudo/CollisionShape2D.disabled:
        if debug_escudo:
            $Escudo/CollisionShape2D/ColorRect.color.a = 0.1
        $Escudo/CollisionShape2D.disabled = false

    elif not defensa && not $Escudo/CollisionShape2D.disabled:
        if debug_escudo:
            $Escudo/CollisionShape2D/ColorRect.color.a = 0
        $Escudo/CollisionShape2D.disabled = true
    
    # Atacar
    if atacar and not atacando and not defensa:
        ataque_tiempo = 0
        atacando = true
        combate = true
        tiempo_combate = 0.0
        audio_ataque()
        #debug
        #$AreaAtaque/CollisionPolygon2D/ColorDebug.color.a = 255
        if anim_ataque == "Ataque_1":
            $AreaAtaque/AnimationPlayer.play("CorteA")
        else:
            $AreaAtaque/AnimationPlayer.play("CorteB")
        var cuerpos = $AreaAtaque.get_overlapping_bodies()
        for c in cuerpos:
            if c.is_in_group("Enemigo"):
                #audio_golpe()
                c.danio(15)
            if c.is_in_group("Cuerda"):
                c.cortar()
    elif atacando:
        ataque_tiempo += delta
        #debug
        #$AreaAtaque/CollisionPolygon2D/ColorDebug.color.a = 1-(ataque_tiempo/RETRASO_ATAQUE)
        if ataque_tiempo >= RETRASO_ATAQUE:
            #$AreaAtaque/CollisionPolygon2D/ColorDebug.color.a = 0.0
            atacando = false
            if anim_ataque == "Ataque_1":
                anim_ataque = "Ataque_2"
            else:
                anim_ataque = "Ataque_1"

    ### ANIMACIÓN ###
    
    var nueva_anim = "Idle"
    if anim_escudo:
        nueva_anim = "Idle_Escudo"
    if sentado:
        nueva_anim = "Sentarse"
        
    if en_piso:
        if dash:
            nueva_anim = "Dash"
        
        if is_on_wall():
            #revisar si collisionamos
            var c_c = get_slide_count()
            for i in range(0,c_c):
                #info de collision
                var col = get_slide_collision(i)
                if col.collider.is_in_group("Caja"):
                    col.collider.apply_impulse(Vector2(0.0,0.0),Vector2(VEL_CAJA*col.normal.x,-2.0))
                elif col.collider.is_in_group("Tronco"):
                    col.collider.move_and_slide(col.normal*-1*300)
                    
        
        if vel_linear.x < -VEL_CAMBIO_DIR:
            area_ataque.scale.x = -1
            sprite.scale.x = -1*Sprite_Scale
            escudo.scale.x = -1
            if not dash:
                if caminar:
                    nueva_anim = "Caminar"
                else:
                    nueva_anim = "Correr"

        if vel_linear.x > VEL_CAMBIO_DIR:
            area_ataque.scale.x = 1
            sprite.scale.x = 1*Sprite_Scale
            escudo.scale.x = 1
            if not dash:
                if caminar:
                    nueva_anim = "Caminar"
                else:
                    nueva_anim = "Correr"
    else:
        # Queremos que el personaje cambie inmediatamente de dirección cuando el jugador
        # intente cambiar de dirección, durante control aereo.
        # Esto permite al personaje atacar rapidamente izquierda y derecha.
        if Input.is_action_pressed("mover_izq") and not Input.is_action_pressed("mover_der"):
            area_ataque.scale.x = -1
            sprite.scale.x = -1*Sprite_Scale
            escudo.scale.x = -1
        if Input.is_action_pressed("mover_der") and not Input.is_action_pressed("mover_izq"):
            area_ataque.scale.x = 1
            sprite.scale.x = 1*Sprite_Scale
            escudo.scale.x = 1

        if vel_linear.y < 0:
            nueva_anim = "Salto_A"
        else:
            nueva_anim = "Salto_B"
    
    if atacando:
        nueva_anim = anim_ataque
    if defensa:
        nueva_anim = "Defensa"
        
    #ANIMACION DE COMBATE
    if combate:
        tiempo_combate += delta
        if tiempo_combate >= T_MAX_COMBATE:
            combate = false
    if combate and en_piso and not (atacar or atacando or defensa or mover_izq or mover_der or saltar):
        nueva_anim = "Combate"

    if nueva_anim != anim:
        anim = nueva_anim
        $AnimationPlayer.play(anim)


func _on_AreaAtaque_body_entered(body):
	print(body, body.is_in_group("breakable"))
	if body.is_in_group("breakable"):
		body.get_parent().take_damage()
