@icon("res://Node Icons/node/icon_brain.png")
class_name Game_Manager extends Node

## Holds the current level number - 1. Should never be greater than or equal to [member grv_File_Loader.levelcount].
var level: int = 0

## Holds the 7 color palettes used by the game.
const palettes = [
    ["blue", "brown"],
    ["red", "gray"],
    ["pink", "green"],
    ["green", "pink"],
    ["brown", "cyan"],
    ["cyan", "blue"],
    ["gray", "red"]
]

var game_clock: Timer

var obj_frames: Dictionary[Item.Type, SpriteFrames] = {Item.Type.CHERRY: preload("res://themes/default/objects/cherry.tres"), Item.Type.AMMO: preload("res://themes/default/objects/ammo.tres"), Item.Type.PLAYER: preload("res://themes/default/objects/player.tres"), Item.Type.APPLE: preload("res://themes/default/objects/apple.tres"), Item.Type.DIAMOND: preload("res://themes/default/objects/diamond.tres")}

## Holds a reference to the game scene's root node.
var gamescene: Node

## Holds the current color palette. See [constant palettes] for the list of color palettes.
var palette: Array = palettes[0]

## Holds the unparsed tile data for dirt, walls, and soft_walls. See [method Level_Builder.build_ground] for how to interpret the information.
var tiles: Array

## Holds a [enum MOVE_TYPE] for each tile in the level.
var move_types: Array

## The lower bound for x positions, in tiles.
const min_x = 0
## The upper bound for x positions, in tiles.
const max_x = 39
## The lower bound for y positions, in tiles.
const min_y = 0
## The upper bound for y positions, in tiles.
const max_y = 21

## The terrains for each color of dirt.
const dirt = {"blue": 14, "brown": 15, "red": 16, "gray": 17, "pink": 18, "green": 19, "cyan": 20}

## The terrains for each color of wall.
const walls = {"blue": 7, "brown": 8, "red": 9, "gray": 10, "pink": 11, "green": 12, "cyan": 13}

## The terrains for each color of soft wall.
const soft_walls = {"gray": 0, "blue": 1, "brown": 2, "red": 3, "pink": 4, "green": 5, "cyan": 6}

## Holds the colors used for the background of each color.
const colors = {"blue": Color("#0020aa"), "brown": Color("#a97142"), "red": Color("#aa0f00"), "gray": Color("#aaaaaa"), "pink": Color("#aa23aa"), "green": Color("#02aa00"), "cyan": Color("#00aaaa")}

## Holds the text color used for each color.
const text_colors = {"blue": Color.WHITE, "red": Color.WHITE, "brown": Color.WHITE, "gray": Color.BLACK, "pink": Color.WHITE, "green": Color.WHITE, "cyan": Color.WHITE}

## Defines the four movement "types" which denote what properties a tile has for movement purposes.
enum MOVE_TYPE {
    EMPTY,
    DIG,
    ROCK,
    BLOCKED
}

func _ready():
    RenderingServer.set_default_clear_color(colors[palette[0]])
    preload("res://grvtheme.tres").set_color("font_color", "Label", text_colors[palette[0]])
    gamescene = $"../game"

## Takes two tile coordinates ([param to] and [param from]) and returns the [enum MOVE_TYPE] that corresponds to that tile [b]given the movement being attempted[b].[br][br]For example, if the player is moving into a rock that cannot be pushed, it will return MOVE_TYPE_BLOCKED, not MOVE_TYPE_ROCK.
func get_movement_type(to: Vector2i, from: Vector2i) -> MOVE_TYPE:
    if to.x < min_x or to.x > max_x:
        return MOVE_TYPE.BLOCKED
    elif to.y < min_y or to.y > max_y:
        return MOVE_TYPE.BLOCKED
    else:
        if move_types[to.y][to.x] == MOVE_TYPE.ROCK:
            var move_offset = to - from
            if move_offset.y == 0:
                var push = to + move_offset
                if move_types[push.y][push.x] == MOVE_TYPE.EMPTY:
                    return MOVE_TYPE.ROCK
                else:
                    return MOVE_TYPE.BLOCKED
            else:
                return MOVE_TYPE.BLOCKED
        else:
            return move_types[to.y][to.x]

## Dig the tile at [param pos].
func dig(pos: Vector2i):
    var tile = tiles[pos.y][pos.x]
    if tile.type == Tile.TYPE.DIRT or tile.type == Tile.TYPE.SOFT_WALL:
        tiles[pos.y][pos.x] = Tile.new(Tile.TYPE.EMPTY, tile.color)
        gamescene.get_node("ground_tiles").set_cells_terrain_connect([pos], 0, -1)
        change_move_type(pos, MOVE_TYPE.EMPTY)

func change_move_type(pos: Vector2i, move_type: MOVE_TYPE):
    move_types[pos.y][pos.x] = move_type

## Gets the [enum MOVE_TYPE] for a given [Tile].
func get_tile_type_move_type(tile_type: Tile):
    match tile_type.type:
        Tile.TYPE.EMPTY:
            return MOVE_TYPE.EMPTY
        Tile.TYPE.DIRT:
            return MOVE_TYPE.DIG
        Tile.TYPE.WALL:
            return MOVE_TYPE.BLOCKED
        Tile.TYPE.SOFT_WALL:
            return MOVE_TYPE.DIG
