@icon("res://Node Icons/node/icon_cell.png")
class_name Tile extends RefCounted

## Holds data about a tile.
##
## Tiles are Empty Space, Dirt, Walls, and Soft Walls, and can have objects on top of them.

## Defines the four types of tiles (including empty space).
enum TYPE {
    EMPTY,
    DIRT,
    WALL,
    SOFT_WALL
}

## Defines the two color types. The actual color can be accessed using [member Game_Manager.palette].
enum COLOR {
    PRIMARY,
    SECONDARY
}

## Holds the type of tile. See [enum TYPE].
@export var type: TYPE

## Holds the color of the tile. See [enum COLOR].
@export var color: COLOR

func _init(tile_type: TYPE, tile_color: COLOR):
    type = tile_type
    color = tile_color
