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

## Holds a reference to the game scene's root node.
var gamescene: Node

## Holds the current color palette. See [constant palettes] for the list of color palettes.
var palette: Array = palettes[5]

## Holds the unparsed tile data for dirt, walls, and soft_walls. See [method LevelBuilder.build_ground] for how to interpret the information.
var tiles: Array

## Holds a [enum MOVE_TYPE] for each tile in the level.
var move_types: Array

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
	if to.x < 0 or to.x > 39:
		return MOVE_TYPE.BLOCKED
	elif to.y < 0 or to.y > 21:
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

## Generates [member move_types] based on [member tiles]. Currently does nothing.
func generate_move_types():
	pass
