extends Node2D
signal reset_to_checkpoint


func _on_DieZone_body_entered(body):
	emit_signal("reset_to_checkpoint")
