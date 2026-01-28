class_name Level_Builder extends Node

##Builds ground tiles from a 2D array of Vector2s.[br]
##The x component is the type. 0 = empty, 1 = dirt, 2 = wall, 3 = soft_wall.[br]
##The y component is the color. This only applies when x > 0. 0 = color_1, 1 = color_2.
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
			match Vector2i(tiles[row][tile]).x:
				0:
					empty.append(Vector2i(tile, row))
				1:
					match Vector2i(tiles[row][tile]).y:
						1:
							dirt1.append(Vector2i(tile, row))
						0:
							dirt0.append(Vector2i(tile, row))
				2:
					match Vector2i(tiles[row][tile]).y:
						1:
							walls1.append(Vector2i(tile, row))
						0:
							walls0.append(Vector2i(tile, row))
				3:
					match Vector2i(tiles[row][tile]).y:
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

func _ready():
	build_ground([
		[Vector2(0, 0), Vector2(0, 0)],
		[Vector2(0, 0), Vector2(1, 1), Vector2(1, 0), Vector2(1, 0)],
		[Vector2(0, 0), Vector2(1, 1), Vector2(1, 1), Vector2(1, 0)],
		[Vector2(0, 0), Vector2(2, 1), Vector2(2, 0), Vector2(2, 0)],
		[Vector2(0, 0), Vector2(2, 1), Vector2(2, 1), Vector2(2, 0)]
	])
