extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_life = $Player.life
	
	$GUI.set_max_life(player_life)
	$GUI.update_life(player_life)
	$Player.connect("update_life", $GUI, "update_life")
	$Vineta1.connect("reset_to_checkpoint", self, "reset_to_checkpoint")
	#$Bomb.connect("can_be_grabbed", $Player, "can_grab_item")
	#$Bomb.connect("can_not_be_grabbed", $Player, "can_not_grab_item")

func _physics_process(delta):
	#por si se me olvida calcular la distancia absoluta entre dos vectores
	#var distance = sqrt(pow($Player.global_position.x - $GUI.rect_global_position.x, 2) + pow($Player.global_position.y - $GUI.rect_global_position.y, 2))
	var camera_position = $Player/Camera2D.get_camera_position()
	$GUI.rect_global_position.x = camera_position.x - 550
	$GUI.rect_global_position.y = camera_position.y - 350

func reset_to_checkpoint():
	$Player.position.x = $Vineta1/StartPosition.position.x
	$Player.position.y = $Vineta1/StartPosition.position.y