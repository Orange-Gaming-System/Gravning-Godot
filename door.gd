@icon("res://Node Icons/node_2D/icon_door.png")
class_name Door extends TimedObj

func _ready():
    GameManager.queue.add(event, map_tile.tmr.fval, map_tile.prio)
    sprite_frames = preload("res://themes/default/objects/doors.tres")
    position = board_pos * 16

func event(_timeritem):
    map_tile.rmv_obj()
    return true
