extends Node

var level = 0

var palletes = [
	["blue", "brown"],
	["red", "gray"],
	["pink", "green"],
	["green", "pink"],
	["brown", "cyan"],
	["cyan", "blue"],
	["gray", "red"]
]

var gamescene: Node

var pallete: Array = palletes[5]

var tiles: Array

var move_types: Array

const dirt = {"blue": 14, "brown": 15, "red": 16, "gray": 17, "pink": 18, "green": 19, "cyan": 20}

const walls = {"blue": 7, "brown": 8, "red": 9, "gray": 10, "pink": 11, "green": 12, "cyan": 13}

const soft_walls = {"gray": 0, "blue": 1, "brown": 2, "red": 3, "pink": 4, "green": 5, "cyan": 6}

const colors = {"blue": Color("#0020aa"), "brown": Color("#a97142"), "red": Color("#aa0f00"), "gray": Color("#aaaaaa"), "pink": Color("#aa23aa"), "green": Color("#02aa00"), "cyan": Color("#00aaaa")}

const text_colors = {"blue": Color.WHITE, "red": Color.WHITE, "brown": Color.WHITE, "gray": Color.BLACK, "pink": Color.WHITE, "green": Color.WHITE, "cyan": Color.WHITE}

##Defines the four movement "types" which denote what properties a tile has for movement purposes.
enum MOVE_TYPE {
	EMPTY,
	DIG,
	ROCK,
	BLOCKED
}

func _ready():
	RenderingServer.set_default_clear_color(colors[pallete[0]])
	preload("res://grvtheme.tres").set_color("font_color", "Label", text_colors[pallete[0]])
	gamescene = $"../game"

##Takes two tile coordinates ([param to] and [param from]) and returns the [enum MOVE_TYPE] that corresponds to that tile [b]given the movement being attempted[b].[br][br]For example, if the player is moving into a rock that cannot be pushed, it will return MOVE_TYPE_BLOCKED, not MOVE_TYPE_ROCK.
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
