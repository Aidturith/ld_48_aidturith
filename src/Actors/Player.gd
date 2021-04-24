extends Actor

export var drill_speed := Vector2(500.0, 350.0)

var drill_jump := false
var state

enum States {
	NORMAL,
	DRILL_FLOOR,
	#DRILL_CEILLING,
	DRILL_WALL_UP,
	#DRILL_WALL_DOWN,
	DRILL_JUMP,
}

func _ready():
	pass
	
func _physics_process(delta: float) -> void:
	var direction = get_direction()
	if direction.x != 0:
		facing.x = direction.x
	update_state(direction)
	if drill_jump and is_on_floor():
		drill_jump = false
	if direction.y == -1.0 and is_drilling_floor():
		drill_jump = true
	velocity = compute_move_velocity(velocity, direction)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)


func update_state(direction: Vector2) -> void:
	#if is_falling() and not state in [States.NORMAL] and $DrillFallDelay.time_left == 0:
	#	$DrillFallDelay.start()
	#elif not is_falling() and  $DrillFallDelay.time_left > 0:
	#	$DrillFallDelay.stop()
	var pressed_drill = Input.is_action_pressed("drill")
	if not pressed_drill or is_falling():
		state = States.NORMAL
	elif is_on_floor() and pressed_drill:
		state = States.DRILL_FLOOR
	if is_on_wall() and (state in [States.DRILL_FLOOR, States.DRILL_WALL_UP]):
		state = States.DRILL_WALL_UP
	#elif is_on_wall() and state in [States.DRILL_CEILLING, States.DRILL_WALL_DOWN]:
	#	state = States.DRILL_WALL_DOWN
	#elif is_on_ceiling() and state in [States.DRILL_WALL_UP]:
	#	facing.x = -facing.x
	#	state = States.DRILL_CEILLING
	#elif is_on_floor() and state in [States.DRILL_WALL_DOWN]:
	#	facing.x = -facing.x
	#	state = States.DRILL_FLOOR


#func _on_DrillFallDelay_timeout():
#	state = States.NORMAL


func is_falling() -> bool:
	return not (is_on_floor() or is_on_wall() or is_on_ceiling())


func compute_move_velocity(
		old_velocity: Vector2,
		direction: Vector2) -> Vector2:
	var speed = get_speed()
	var new := old_velocity
	new.x = speed.x * direction.x
	new.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		new.y = speed.y * direction.y
	return new


func get_speed() -> Vector2:
	return drill_speed if is_drilling() else walk_speed


func get_direction() -> Vector2:
	var h_move = get_h_move()
	var v_move = get_v_move()
	return Vector2(h_move, v_move)
	
	
func get_h_move() -> float:
	if state in [States.DRILL_FLOOR]:
		return facing.x
	else:
		var move_right := Input.get_action_strength("move_right")
		var move_left := Input.get_action_strength("move_left")
		return move_right - move_left


func get_v_move() -> float:
	if state in [States.DRILL_WALL_UP]:
		return -1.0
	#elif state in [States.DRILL_WALL_DOWN]:
	#	return 1.0
	elif state in [States.NORMAL, States.DRILL_FLOOR] and is_on_floor() and jumped():
		return -1.0
	else:
		return 1.0


func is_drilling() -> bool:
	return is_drilling_floor() or is_drilling_jump()


func is_drilling_floor() -> bool:
	return is_on_floor() and Input.is_action_pressed("drill")


func is_drilling_jump() -> bool:
	return drill_jump


func jumped() -> bool:
	return Input.is_action_just_pressed("jump")
