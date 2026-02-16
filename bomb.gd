@icon("res://Node Icons/node_2D/icon_event.png")
class_name Bomb extends TimedObj

## Holds the collumn index of [bomb_pattern] where the actual bomb is.
var pattern_offset: int = 5

## Determines the height of each collumn in the pattern. The actual height is given by the formula: (2x + 1).
var bomb_pattern: Array[int] = [0, 0, 2, 2, 3, 3, 3, 2, 2, 0, 0]

func _ready():
    super._ready()
    play("default")

func instant_detonate():
    var new_time = GameTime.now() + 4
    if timeritem.time > new_time:
        timeritem.disable()
        timeritem = GameManager.queue.add(event, new_time, map_tile.prio)

func event(_timeritem, smash = false):
    for index in bomb_pattern.size():
        var x = int(index + board_pos.x - pattern_offset)
        for tile in (bomb_pattern[index] * 2) + 1:
            var y = int(tile + board_pos.y - bomb_pattern[index])
            if smash and Vector2i(x, y) == Vector2i(board_pos):
                continue
            GameManager.bomb_tile(Vector2i(x, y))
    if smash:
        queue_free()
    else:
        map_tile.rmv_obj()
    return true
