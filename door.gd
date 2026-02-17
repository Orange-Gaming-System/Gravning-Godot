@icon("res://Node Icons/node_2D/icon_door.png")
class_name Door extends TimedObj

func _ready():
    super._ready()
    animation = map_tile.item.visual_str()

func event(_timeritem):
    map_tile.rmv_obj()
    return true
