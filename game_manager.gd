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

const dirt = {"blue": 14, "brown": 15, "red": 16, "gray": 17, "pink": 18, "green": 19, "cyan": 20}

const walls = {"blue": 7, "brown": 8, "red": 9, "gray": 10, "pink": 11, "green": 12, "cyan": 13}

const soft_walls = {"gray": 0, "blue": 1, "brown": 2, "red": 3, "pink": 4, "green": 5, "cyan": 6}

const colors = {"blue": Color("#0020aa"), "brown": Color("#a97142"), "red": Color("#aa0f00"), "gray": Color("#aaaaaa"), "pink": Color("#aa23aa"), "green": Color("#02aa00"), "cyan": Color("#00aaaa")}

const text_colors = {"blue": Color.WHITE, "red": Color.WHITE, "brown": Color.WHITE, "gray": Color.BLACK, "pink": Color.WHITE, "green": Color.WHITE, "cyan": Color.WHITE}

func _ready():
	RenderingServer.set_default_clear_color(colors[pallete[0]])
	preload("res://grvtheme.tres").set_color("font_color", "Label", text_colors[pallete[0]])
	gamescene = $"../game"
