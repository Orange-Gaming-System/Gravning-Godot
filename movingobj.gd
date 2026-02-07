class_name MovingObj extends GrvObj

## Holds the board position of the object at the start of the tick.
var start_pos: Vector2
## Holds the board position the object is currently moving to.
var goal_pos: Vector2

func _process(_delta):
	board_pos = lerp(start_pos, goal_pos, %game_clock.time_ratio)
	position = board_pos * 16

func _ready():
	super._ready()
	%game_clock.timeout.connect(Callable(self, "_new_tick"))
	start_pos = board_pos
	goal_pos = board_pos
