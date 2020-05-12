extends KinematicBody2D

onready var wait_timer: Timer = $Timer
onready var wayponts: = get_node(waypoints_path)

export var editor_process: = true setget set_editor_process
export var speed: = 400.0

export var waypoints_path: = NodePath()
var target_position: = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not wayponts:
		set_physics_process(false)
		return
	position = wayponts.get_start_position()
	target_position = wayponts.get_next_point_position()

func _physics_process(delta):
	var direction: = (target_position - position).normalized()
	var motion = direction * speed * delta
	var distance_to_target: = position.distance_to(target_position)
	
	if motion.length() > distance_to_target:
		position = target_position
		target_position = wayponts.get_next_point_position()
		set_physics_process(false)
		wait_timer.start()
	else:
		position += motion

func set_editor_process(value: bool) -> void:
	pass

func _on_Timer_timeout() -> void:
	set_physics_process(true)
