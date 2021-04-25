extends Area2D

var trex_factory = preload("res://src/Actors/Trex.tscn")

func _process(delta):
	pass
#	overlapping_tiles()

#func overlapping_tiles():
#	var extents = $CollisionShape2D.shape.extents
#	#print(extents)
#	var tilemap = get_tree().root.get_node('LevelTemplate/TileMap')
#	var global_pos = $CollisionShape2D.global_position
#	var local_pos = tilemap.to_local(global_pos)
#	for x in range(0, extents.x, 128):
#		for y in range(0, -extents.y, 128):
#			var new_local = Vector2(x + local_pos.x, y - local_pos.y)
#			var tile_pos = tilemap.world_to_map(new_local)
#			print(tile_pos)
#	#var upper_tile_pos = node_tile_position(tilemap, $CollisionShape2D)
#	#var lower_tile_pos = node_to_tile_position(tilemap, $CollisionShape2D)
#	#var tile_pos = tilemap.world_to_map(local_pos)


#func node_tile_position(tilemap:TileMap, node: Node2D):
#	var global = node.global_position
#	var local = tilemap.to_local(global)
#	return tilemap.world_to_map(local)
	

#func global_to_tile_position(tilemap:TileMap, global: Vector2):
#	var local = tilemap.to_local(global)
#	return tilemap.world_to_map(local)


func _on_TrexBones_body_shape_exited(body_id, body, body_shape, local_shape):
	print(body.name)
	pass # Replace with function body.


func _on_TrexBones_area_shape_exited(area_id, area, area_shape, local_shape):
	print(area.name)
	pass # Replace with function body.


func _on_TrexBones_area_exited(area):
	print(area.name)
	pass # Replace with function body.


func _on_TrexBones_body_exited(body):
	print(body.name)
	pass # Replace with function body.


func _on_TrexBones_body_entered(body):
	if body.name == "Player":
		$Sprite.hide()
		var trex = trex_factory.instance()
		trex.position = body.position + Vector2.UP * 200
		get_tree().get_root().add_child(trex)
		disconnect("body_entered", self, "_on_TrexBones_body_entered")
