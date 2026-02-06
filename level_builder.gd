@icon("res://Node Icons/node/icon_hammer.png")
class_name Level_Builder extends Node

##Builds ground tiles from a 2D array of [Tile]s.
func build_ground(tiles: Array):
	GameManager.tiles = tiles
	var empty = []
	var dirt0 = []
	var dirt1 = []
	var walls0 = []
	var walls1 = []
	var soft0 = []
	var soft1 = []
	for row in tiles.size():
		for tile in tiles[row].size():
			match tiles[row][tile].type:
				Tile.TYPE.EMPTY:
					empty.append(Vector2i(tile, row))
				Tile.TYPE.DIRT:
					match tiles[row][tile].color:
						1:
							dirt1.append(Vector2i(tile, row))
						0:
							dirt0.append(Vector2i(tile, row))
				Tile.TYPE.WALL:
					match tiles[row][tile].color:
						1:
							walls1.append(Vector2i(tile, row))
						0:
							walls0.append(Vector2i(tile, row))
				Tile.TYPE.SOFT_WALL:
					match tiles[row][tile].color:
						1:
							soft1.append(Vector2i(tile, row))
						0:
							soft0.append(Vector2i(tile, row))
	$"../game/ground_tiles".set_cells_terrain_connect(empty, 0, -1)
	$"../game/ground_tiles".set_cells_terrain_connect(dirt0, 0, GameManager.dirt[GameManager.palette[0]])
	$"../game/ground_tiles".set_cells_terrain_connect(dirt1, 0, GameManager.dirt[GameManager.palette[1]])
	$"../game/ground_tiles".set_cells_terrain_connect(walls0, 0, GameManager.walls[GameManager.palette[0]])
	$"../game/ground_tiles".set_cells_terrain_connect(walls1, 0, GameManager.walls[GameManager.palette[1]])
	$"../game/ground_tiles".set_cells_terrain_connect(soft0, 0, GameManager.soft_walls[GameManager.palette[0]])
	$"../game/ground_tiles".set_cells_terrain_connect(soft1, 0, GameManager.soft_walls[GameManager.palette[1]])

## Sets [member Game_Manager.move_types] based on the corresponding tile. Does not account for objects.
func set_move_types():
	var tiles = GameManager.tiles
	var movetypes = []
	for row in tiles.size():
		var row_array = []
		for tile in tiles[row].size():
			row_array.append(GameManager.get_tile_type_move_type(tiles[row][tile]))
		movetypes.append(row_array)
	GameManager.move_types = movetypes

# Temporary Constants for test level.
@warning_ignore("int_as_enum_without_cast")
var ent = Tile.new(0, 0)
@warning_ignore("int_as_enum_without_cast")
var swp = Tile.new(3, 0)
@warning_ignore("int_as_enum_without_cast")
var sws = Tile.new(3, 1)
@warning_ignore("int_as_enum_without_cast")
var wwp = Tile.new(2, 0)
@warning_ignore("int_as_enum_without_cast")
var wws = Tile.new(2, 1)

func _ready():
	build_ground([
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent],
		[ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent, ent]
		])
	set_move_types()
