extends Sprite

export (int) var durability = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body
	
func take_damage():
	print(self.durability)
	self.durability -= 1
	if self.durability == 0:
		queue_free()