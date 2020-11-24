extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_life = $Player.life
	
	$HUD/GUI.set_max_life(player_life)
	$HUD/GUI.update_life(player_life)
	$Player.connect("update_life", $HUD/GUI, "update_life")
	$Vineta1.connect("reset_to_checkpoint", self, "reset_to_checkpoint")
	$Vineta1/DestructibleBorder.connect("tween_camera_right", $Player, "tween_camera_right")
	$Vineta1/DestructibleBorder2.connect("tween_camera_right", $Player, "tween_camera_right")
	$Vineta1/DestructibleBorder3.connect("tween_camera_right", $Player, "tween_camera_right")
	$Apple.connect("can_be_grabbed", $Player, "can_grab_item")
	$Apple.connect("can_not_be_grabbed", $Player, "can_not_grab_item")
	$Player.connect("destroyItem", self, "destroyItem")
	

func destroyItem(itemName):
	get_node(itemName).queue_free()

func reset_to_checkpoint():
	$Player.position.x = $Vineta1/StartPosition.position.x
	$Player.position.y = $Vineta1/StartPosition.position.y
