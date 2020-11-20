extends Area2D
export (bool) var can_grab_item = false

var player_on_range = false

signal can_be_grabbed
signal can_not_be_grabbed

func _on_Area2D_body_entered(body):
	self.player_on_range = true
	emit_signal("can_be_grabbed", {
		"itemName": "Bomb",
		"itemFunction": "recoverHealth",
		"functionParams": {
			"health": 30
		}
	})

func _on_Bomb_body_exited(body):
	self.player_on_range = false
	emit_signal("can_not_be_grabbed")
