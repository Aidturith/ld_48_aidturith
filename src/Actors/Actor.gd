extends KinematicBody2D
class_name Actor

const FLOOR_NORMAL := Vector2.UP
const CEILLING_NORMAL := Vector2.DOWN

export var walk_speed := Vector2(250.0, 250.0)
export var gravity := 3000.0

var velocity := Vector2.ZERO
var facing := Vector2(1.0, -1.0)


func _ready():
	pass

func _physics_process(delta: float) -> void:
	# TODO slide and snap
	#velocity.y += gravity * delta
	# velocity.y = max(velocity.y, speed.y)
	pass
