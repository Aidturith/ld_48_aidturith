extends Node2D

const DESTROYABLE_TILE = 19
var tiles_to_destroy = []

var rng = RandomNumberGenerator.new()

onready var player = $".."/Player


func _ready():
	rng.randomize()


func _physics_process(delta):
	process_destructions()
	

func process_destructions():
	if tiles_to_destroy.size() > 0 and $TileDestruction.time_left == 0:
		var to_destroy = tiles_to_destroy.pop_front()
		$Sand.set_cellv(to_destroy, -1)
		$Sand.update_bitmask_region()  # TODO could use some optimisation
		play_random_sfx()
		$TileDestruction.start()


func play_random_sfx():
	var i = rng.randi() % 4 + 1
	get_node("SFX/TileDestruct" + str(i)).play()


func global_to_tile(global_pos, tile_map):
	var local_pos = tile_map.to_local(global_pos)
	return tile_map.world_to_map(local_pos)


func _on_Player_destroy_tile(destruct_positions: Array) -> void:
	for pos in destruct_positions:
		var tile = global_to_tile(pos, $Sand)
		if $Sand.get_cellv(tile) != -1 and not tile in tiles_to_destroy:
			tiles_to_destroy.append(tile)
	#print(tile)
	#var behind = tile - Vector2.LEFT
	#if $Sand.get_cellv(behind) != -1 and not behind in tiles_to_destroy:
	#	tiles_to_destroy.append(behind)
