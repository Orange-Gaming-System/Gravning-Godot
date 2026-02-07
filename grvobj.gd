@icon("res://Node Icons/node_2D/icon_crate.png")
class_name GrvObj extends AnimatedSprite2D

## Holds the current player position in tiles. Is floating point to avoid snappy movement.
@export var board_pos: Vector2

func _ready():
	position = board_pos * 16
