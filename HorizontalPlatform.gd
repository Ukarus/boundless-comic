extends Node2D

export (int) var speed
export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0
var velocity = Vector2()

func _ready():
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()


func _physics_process(delta):
	if !patrol_path:
		return
	var target = patrol_points[patrol_index]
	if position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - position).normalized() * speed
	velocity = $KinematicBody2D.move_and_slide(velocity)
	#ruta.set_offset(ruta.get_offset() + speed * delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
