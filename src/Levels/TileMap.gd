extends TileMap

const DESTROYABLE_TILE = 19
var tiles_to_destroy = []

var rng = RandomNumberGenerator.new()

onready var player = $".."/Player

func _ready():
	rng.randomize()

func _physics_process(delta):
	process_destructions()
	if player.state in [player.States.DRILL_FLOOR]:
		var standing_tile = get_player_tile()
		if (get_cellv(standing_tile) == DESTROYABLE_TILE
			and not standing_tile in tiles_to_destroy):
			tiles_to_destroy.append(standing_tile)
			self.set_cellv(standing_tile, DESTROYABLE_TILE, false, true)


func process_destructions():
	if tiles_to_destroy.size() > 0 and $TileDestruction.time_left == 0:
		var to_destroy = tiles_to_destroy.pop_front()
		self.set_cellv(to_destroy, -1)
		play_random_sfx()
		$TileDestruction.start()

func play_random_sfx():
	var i = rng.randi() % 4 + 1
	get_node("SfxTileDestruct" + str(i)).play()


func get_player_tile():
	var player_global_pos = player.global_position
	var player_local_pos = self.to_local(player_global_pos)
	return self.world_to_map(player_local_pos)
