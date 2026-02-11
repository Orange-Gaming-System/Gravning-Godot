class_name MovingObj extends GrvObj

## Holds the board position of the object at the start of the tick.
var start_pos: Vector2
## Holds the board position the object is currently moving to.
var goal_pos: Vector2

func _process(_delta):
    board_pos = lerp(start_pos, goal_pos, GameManager.game_clock.time_ratio)
    position = board_pos * 16

func _ready():
    super._ready()
    start_pos = board_pos
    goal_pos = board_pos

func _new_tick():
    map_tile = map_tile.moveto(goal_pos)
