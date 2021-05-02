extends Actor

export var drill_speed := Vector2(500.0, 250.0)

export var debug = true

var state = States.NORMAL

var direction = Vector2.RIGHT
var normal = Vector2.UP
var target_rotation = 0.0

var _destructions = []
signal destroy_tile

enum States {
	NORMAL,
	#JUMP,
	DRILL_FLOOR,
	DRILL_WALL_UP,
	#DRILL_JUMP,
	#DRILL_BOUNCE,
}


func _ready():
	var tile_size = 32
	var poll_rate = (1 / (drill_speed.x / tile_size))
	#var poll_rate = 0.025
	$Timers/DestructPoller.wait_time = 0.16
	$Timers/RotatePoller.wait_time = poll_rate


func _process(delta):
	var title = "Drilling v0.1"
	OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))
	update_sprite()
	update_sfx(delta)
	

func update_sprite() -> void:
	if drilling():
		$CollisionStanding.disabled = true
		$CollisionDrilling.disabled = false
		$AnimatedSprite.play('drill')
	else:
		$CollisionStanding.disabled = false
		$CollisionDrilling.disabled = true
		$AnimatedSprite.play('stand')


func update_sfx(delta: float) -> void:
	# TODO use velocity instead ? same for to be animations ?
	if drilling() and not $SFX/Drill.playing:
		$SFX/Drill.pitch_scale = 1.0
		$SFX/Drill.play()
	elif drilling():
		tone_up_drill_sfx(delta)
	else:
		tone_down_drill_sfx(delta)


func tone_up_drill_sfx(delta: float) -> void:
	if $SFX/Drill.pitch_scale < 2.0:
		$SFX/Drill.pitch_scale += delta / 2
	
	
func tone_down_drill_sfx(delta: float) -> void:
	if $SFX/Drill.pitch_scale > 1.0:
		$SFX/Drill.pitch_scale -= delta / 2
	else:
		$SFX/Drill.stop()


func _physics_process(delta):
	emit_destructions()
	if drill_started(): $Timers/DrillStart.start()
	if debug: get_debug_inputs()
	get_inputs(delta)
	$DebugDraw.add(velocity, Color.red)
	if target_rotation != 0:
		rotation = lerp_angle(rotation, target_rotation, 0.7)
		var new_normal = normal.rotated(rotation)
		var new_direction = direction.rotated(rotation)
		velocity = new_direction * drill_speed.x - new_normal * drill_speed.y
	velocity = move_and_slide(velocity, normal)
	$DebugDraw.add(velocity, Color.blue)
	$DebugDraw.update()


func get_debug_inputs():
	if Input.is_action_just_pressed("debug_rotate"):
		#var quarter = PI / 2 * direction.x
		rotation += 0.1
		print("debug rotate, ", rotation)


func get_inputs(delta):
	if check_bounce(delta):
		$SFX/DrillBounce.play()
		Input.action_release("drill")
		velocity = Vector2(-direction.x * 500, -500.0)
		return
	if drill_starting():
		var top_speed = speed.x * direction.x * 2
		velocity.x = lerp(velocity.x, top_speed, 0.01)
	elif drilling():
		var top_speed = speed.x * direction.x * 2
		velocity.x = lerp(velocity.x, top_speed, 0.2)
	elif move_right() and move_left():
		velocity.x = lerp(velocity.x, 0.0, 0.2)
	elif move_right():
		flip_sprite(true)
		velocity.x = lerp(velocity.x, speed.x, 0.5)
	elif move_left():
		flip_sprite(false)
		velocity.x = lerp(velocity.x, -speed.x, 0.5)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)
	velocity.y += gravity
	if jumped() and is_on_floor():
		$SFX/Jump.play()
		velocity.y = speed.y
	check_wallride_on()
	check_wallride_off()


func flip_sprite(flip):
	$AnimatedSprite.flip_h = flip
	var front_pos = abs($FrontCollider.position.x)
	if flip:
		direction = Vector2.RIGHT
		$FrontCollider.position.x = front_pos
	else:
		direction = Vector2.LEFT
		$FrontCollider.position.x = -front_pos


func check_bounce(delta):
	if drilling() and velocity.length() > 500.0 and face_rock():
		return true
	return false


func check_wallride_on():
	if drilling() and face_sand():
		target_rotation += (PI / 2) * -direction.x
		if target_rotation > 2 * PI or target_rotation < -2 * PI:
			target_rotation = 0.0


func check_wallride_off():
	if drilling() and on_sand():
		$Timers/RotatePoller.start()
	var time_left = $Timers/RotatePoller.time_left
	if target_rotation != 0.0 and time_left == 0.0:
		normal = Vector2.UP
		rotation = 0.0
		target_rotation = 0.0


func emit_destructions():
	if drilling() and velocity.length() > 250.0 and on_sand():
		_destructions.append($FloorCollider.global_position)
	if _destructions.size() > 0 and $Timers/DestructPoller.time_left == 0:
		emit_signal("destroy_tile", _destructions)
		$Timers/DestructPoller.start()
		_destructions = []
		


func on_sand(): return on("sand")
func on(group):
	for body in $FloorCollider.get_overlapping_bodies():
		if body.is_in_group(group):
			return true
	return false


func face_rock(): return face("rock")
func face_sand(): return face("sand")
func face(group):
	for body in $FrontCollider.get_overlapping_bodies():
		if body.is_in_group(group):
			return true
	return false


func jumped():
	return Input.is_action_just_pressed("jump")


func drilling():
	return Input.is_action_pressed("drill")


func drill_started():
	return Input.is_action_just_pressed("drill")


func drill_starting() -> bool:
	return $Timers/DrillStart.time_left > 0.0


func move_left():
	return Input.is_action_pressed('move_left')
	
	
func move_right():
	return Input.is_action_pressed('move_right')
