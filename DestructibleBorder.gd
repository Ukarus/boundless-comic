extends StaticBody2D

export (int) var durability = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")
	
func take_damage(dmg):
	self.durability -= dmg
	if self.durability == 2:
		$DamageTile.play()
		$AnimationPlayer.play("second")
	if self.durability == 1:
		$DamageTile.play()
		$AnimationPlayer.play("third")
	if self.durability == 0:
		$BreakTile.play()
		$AnimationPlayer.play("final")