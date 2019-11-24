extends Node2D

const IDLE_DURATION = 1.0
export var move_to = Vector2.UP * 200
export var speed = 6

var follow = Vector2.ZERO

onready var platform = $Platform
onready var move_tween = $Tween

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_tween()

func _init_tween():
	var duration = move_to.length() / float(speed * 96) 
	move_tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, duration, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, IDLE_DURATION)
	move_tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)
	move_tween.start()

func _physics_process(delta):
	platform.position = platform.position.linear_interpolate(follow, 0.075)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
