extends Control

var vectors = []
var colors = []
	
func _draw():
	var parent = get_parent().rotation
	while vectors.size() > 0:
		var v = vectors.pop_front()
		var c = colors.pop_front()
		draw_line(Vector2.ZERO, v.rotated(-parent), c, 5, false)

func add(vector, color):
	vectors.append(vector)
	colors.append(color)

func norm(vector: Vector2) -> Vector2:
	return vector.normalized() * 64
