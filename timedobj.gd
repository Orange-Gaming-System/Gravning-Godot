class_name TimedObj extends BlockingObj

var timeritem: TimerItem

func _ready():
    timeritem = GameManager.queue.add(event, map_tile.tmr.fval, map_tile.prio)
    super._ready()

func event(_timeritem):
    return true
