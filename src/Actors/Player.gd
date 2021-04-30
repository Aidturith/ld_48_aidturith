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
	if drilling():
		$AnimatedSprite.play('drill')
	else:
		$AnimatedSprite.play('stand')


func update_sfx(delta: float) -> void:
	if drilling() and not $SfxDrillOn.playing:
		$SfxDrillOn.pitch_scale = 1.0
		$SfxDrillOn.play()
	elif drilling():
		tone_up_drill_sfx(delta)
	else:
		tone_down_drill_sfx(delta)


func tone_up_drill_sfx(delta: float) -> void:
	if $SfxDrillOn.pitch_scale < 2.0:
		$SfxDrillOn.pitch_scale += delta / 2
	
	
func tone_down_drill_sfx(delta: float) -> void:
	if $SfxDrillOn.pitch_scale > 1.0:
		$SfxDrillOn.pitch_scale -= delta / 2
	else:
		$SfxDrillOn.stop()


func _physics_process(delta):
	if drill_started():
		$Timers/DrillStart.start()
	if drill_starting():
		var push_back = speed.x * -get_direction() * 4
		velocity.x = lerp(velocity.x, push_back, 0.1)
	elif drilling():
		var top_speed = speed.x * get_direction() * 2
		velocity.x = lerp(velocity.x, top_speed, 0.1)
	elif move_right() and move_left():
		velocity.x = lerp(velocity.x, 0.0, 0.2)
	elif move_right():
		$AnimatedSprite.flip_h = true
		velocity.x = lerp(velocity.x, speed.x, 0.5)
	elif move_left():
		$AnimatedSprite.flip_h = false
		velocity.x = lerp(velocity.x, -speed.x, 0.5)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)
	velocity.y += gravity
	if jumped() and is_on_floor():
		velocity.y = speed.y
	velocity = move_and_slide(velocity, Vector2.UP)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if drilling() and is_on_wall() and collision.collider.is_in_group("rock"):
			Input.action_release("drill")
			velocity.x = speed.x * -collision.remainder.x * 0.8
			velocity.y = speed.y * 0.8
			print(get_slide_count())
		elif drilling() and is_on_wall() and collision.collider.is_in_group("sand"):
			print("sticky")


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


func get_direction():
	return 1 if $AnimatedSprite.flip_h else -1
