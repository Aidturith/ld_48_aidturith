extends Actor

export var drill_speed := Vector2(500.0, 250.0)

var state = States.NORMAL

signal destroy_tile

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
	# TODO use velocity instead ? same for to be animations ?
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
	emit_destructions()
	if drill_started():
		$Timers/DrillStart.start()
	get_inputs(delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	

	#for i in get_slide_count():
	#	var collision = get_slide_collision(i)
	#	if drilling() and is_on_wall() and is_rock(collision):
	#		# TODO detect collisions in wrong order
	#		Input.action_release("drill")
	#		# TODO normal isn't as strong as when pressing right
	#		velocity.x = speed.x * collision.normal.x * 2
	#		velocity.y = speed.y * 0.75
	#		print(get_slide_count())
	#	elif drilling() and is_on_wall() and is_sand(collision):
	#		#print("sticky")
	#		pass
	#	# TODO could do the same with Area2D ? (see collision order)
	#	if (drilling() and abs(velocity.x) > 400.0 
	#			and is_sand(collision) 
	#			and $Timers/DestructPoller.time_left == 0):
	#		$Timers/DestructPoller.start()
	#		emit_signal("destroy_tile", global_position)


func get_inputs(delta):
	if check_bounce(delta):
		# TODO play sfx
		Input.action_release("drill")
		#Input.action_release("move_left")
		#Input.action_release("move_right")
		velocity = Vector2(-get_direction() * 500, -500.0)
		return
	if drill_starting():
		var top_speed = speed.x * get_direction() * 2
		velocity.x = lerp(velocity.x, top_speed, 0.01)
	elif drilling():
		var top_speed = speed.x * get_direction() * 2
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
		velocity.y = speed.y


func flip_sprite(flip):
	$AnimatedSprite.flip_h = flip
	var front_pos = abs($FrontCollider.position.x)
	if flip:
		$FrontCollider.position.x = front_pos
	else:
		$FrontCollider.position.x = -front_pos


func check_bounce(delta):
	var bounce = false
	for body in $FrontCollider.get_overlapping_bodies():
		if drilling() and abs(velocity.x) > 250.0 and body.is_in_group("rock"):
			#var collision = move_and_collide(velocity * delta)
			bounce = true
			#print(collision, " ", body.name)
			#if collision:
			#	bounce = velocity.bounce(collision.normal)
			#	bounce.y = -abs(bounce.x)
	return bounce

func emit_destructions():
	for body in $FloorCollider.get_overlapping_bodies():
		if (drilling() and abs(velocity.x) > 400.0 
				and body.is_in_group("sand") 
				and $Timers/DestructPoller.time_left == 0):
			$Timers/DestructPoller.start()
			emit_signal("destroy_tile", global_position)


func is_sand(collision):
	return collision.collider.is_in_group("sand")


func is_rock(collision):
	return collision.collider.is_in_group("rock")


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
