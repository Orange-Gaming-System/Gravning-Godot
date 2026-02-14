@icon("res://Node Icons/node_2D/icon_door.png")
class_name Door extends TimedObj

func _ready():
    super._ready()
    if map_tile.item.visual == Item.Door.GONE:
        push_warning("GONE-DOOR created at " + str(map_tile.xy) + ".")
    animation = map_tile.item.visual_str()

func event(_timeritem):
    map_tile.rmv_obj()
    return true
