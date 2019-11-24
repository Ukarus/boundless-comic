extends StaticBody2D

export (int) var durability = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")
	
func take_damage(dmg):
	self.durability -= dmg
	if self.durability == 2:
		$AnimationPlayer.play("second")
	if self.durability == 1:
		$AnimationPlayer.play("third")
	if self.durability == 0:
		$AnimationPlayer.play("final")