extends KinematicBody2D

var dir = Vector2(0,0)
var vel = 1000
var dmg = 10

func _physics_process(delta):
	var col = move_and_collide(dir *vel * delta)
	if col:
		var obj = col.collider
		if obj.is_in_group("player"):
			obj.take_damage(dmg)
		#var s = sonido.instance()
		#get_parent().add_child(s)
		#s.set_global_position(get_global_position())
		self.queue_free()
	pass

