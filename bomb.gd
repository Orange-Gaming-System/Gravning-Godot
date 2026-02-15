@icon("res://Node Icons/node_2D/icon_event.png")
class_name Bomb extends TimedObj

func _ready():
    super._ready()
    play("default")

func event(_timeritem):
    map_tile.rmv_obj()
    return true
