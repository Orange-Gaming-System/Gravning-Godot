class_name Map extends RefCounted


## A 2D array of [Tile] which stores all tiles. Each array it contains is 1 row. Accessed as tiles[y][x].
@export var tiles: Array

## An array of [MapTile] which stores all objects (anything that isn't a Wall, Soft Wall, or Empty).
@export var objs: Array
