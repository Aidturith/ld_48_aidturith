extends Camera2D

onready var player = $".."/Player


func _on_Screen2_body_entered(body):
	# TODO follow path instead
	if body.name == "Player":
		translate(Vector2(0, get_viewport().size.y))
		$".."/Bgm.play()
