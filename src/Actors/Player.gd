extends Actor

export var drill_speed := Vector2(500.0, 250.0)

var state = States.NORMAL
var bounced = false

enum States {
	NORMAL,
	#JUMP,
	DRILL_FLOOR,
	DRILL_WALL_UP,
	#DRILL_JUMP,
	#DRILL_BOUNCE,
}


func _process(delta):
	var title = "Drilling v0.1"
	OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))
	update_sprite()
	update_sfx(delta)
	

func update_sprite() -> void:
	match state:
		States.NORMAL:
			$AnimatedSprite.play('stand')
		_:
			$AnimatedSprite.play('drill')
	$AnimatedSprite.flip_h = true if facing.x == 1 else false


func update_sfx(delta: float) -> void:
	match [state, $SfxDrillOn.playing]:
		[States.DRILL_FLOOR, false], \
		[States.DRILL_WALL_UP, false]:
			$SfxDrillOn.pitch_scale = 1.0
			$SfxDrillOn.play()
		[States.DRILL_FLOOR, true], \
		[States.DRILL_WALL_UP, true]:
			tone_up_drill_sfx(delta)
		[States.NORMAL, true]:
			tone_down_drill_sfx(delta)


func tone_up_drill_sfx(delta: float) -> void:
	if $SfxDrillOn.pitch_scale < 2.0:
		$SfxDrillOn.pitch_scale += delta / 2
	
	
func tone_down_drill_sfx(delta: float) -> void:
	if $SfxDrillOn.pitch_scale > 1.0:
		$SfxDrillOn.pitch_scale -= delta / 2
	else:
		$SfxDrillOn.stop()


func _physics_process(delta: float) -> void:
	var direction = get_direction()
	if direction.x != 0:
		facing.x = direction.x
	update_state()
	velocity = compute_move_velocity(velocity, direction)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)


func update_state() -> void:
	var pressed_drill = Input.is_action_pressed("drill")
	bounced = false
	#if state in [States.DRILL_BOUNCE] and is_on_floor():
	#	state = States.NORMAL
	#if state in [States.JUMP, States.DRILL_JUMP, States.DRILL_BOUNCE]:
	#	state = States.NORMAL
	#if pressed_jump:
	#	if is_on_floor() and state in [States.NORMAL]:
	#		state = States.JUMP
	#	elif is_on_floor() and state in [States.DRILL_FLOOR]:
	#		state = States.DRILL_JUMP
	if pressed_drill:
		if is_on_wall():
			bounced = true
		if is_on_floor() and state in [States.NORMAL, States.DRILL_FLOOR]:
			state = States.DRILL_FLOOR
	else:
		state = States.NORMAL


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
	return drill_speed if not state in [States.NORMAL] else walk_speed


func get_direction() -> Vector2:
	var h_move = get_h_move()
	var v_move = get_v_move()
	return Vector2(h_move, v_move)
	
	
func get_h_move() -> float:
	if state in [States.DRILL_FLOOR]:
		return facing.x
	elif bounced:
		return -facing.x
	else:
		var move_right := Input.get_action_strength("move_right")
		var move_left := Input.get_action_strength("move_left")
		return move_right - move_left


func get_v_move() -> float:
	if bounced and is_on_floor():
		return -1.0
	elif jumped() and is_on_floor():
		$SfxJump1.play()
		return -1.0
	else:
		return 1.0

func jumped():
	return Input.is_action_just_pressed("jump")
