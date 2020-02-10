extends Node2D

signal reset_to_checkpoint

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_DieZone_body_entered(body):
	emit_signal("reset_to_checkpoint")
