@icon("res://Node Icons/node_2D/icon_crate.png")
class_name GrvObj extends AnimatedSprite2D

## Holds the current player position in tiles. Is floating point to avoid snappy movement.
@export var board_pos: Vector2

## Holds the [MapTile] originally used to spawn the object.
var map_tile: MapTile

func _ready():
    position = board_pos * 16
    sprite_frames = GameManager.obj_frames[map_tile.item.type]
    GameManager.game_clock.timeout.connect(_new_tick)

func _init(tile: MapTile):
    board_pos = tile.xy
    map_tile = tile

func _new_tick():
    pass

func hit_by_rock():
    map_tile.rmv_obj()

func bombed():
    map_tile.rmv_obj()
