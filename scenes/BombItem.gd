extends Area2D
export (bool) var can_grab_item = false

signal can_be_grabbed
signal can_not_be_grabbed

func _on_Area2D_body_entered(body):
	if (body.is_in_group("player")):
		emit_signal("can_be_grabbed")

func _on_Bomb_body_exited(body):
	if (body.is_in_group("player")):
		emit_signal("can_not_be_grabbed")
