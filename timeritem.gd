class_name TimerItem extends RefCounted

var time        : float
var prio        : int
var event       : Callable
var disabled    : bool

func _init(_event : Callable, _time : float, _prio : int = 0, _disabled : bool = false):
    event = _event
    time = _time
    prio = _prio
    disabled = _disabled

func trigger() -> void:
    event.call(self)

## Disable a pending timer event. The [method poll] function will remove it from
## the queue later without returning.
func disable(off : bool = true):
    disabled = off

# The corresponding sort/bsearch function
static func run_after(a : TimerItem, b : TimerItem) -> bool:
    if a.time != b.time:
        return a.time > b.time
    else:
        return a.prio > b.prio

class Queue extends RefCounted:
    ## This queue is sorted in order of [i]decreasing[/i] time; the next event is at the end
    ## This ordering is more efficient than the other way around.
    var queue : Array[TimerItem]

    func enqueue(_tmr : TimerItem) -> TimerItem:
        queue.insert(queue.bsearch_custom(_tmr, _tmr.run_after, true), _tmr)
        return _tmr

    func add(_event : Callable, _time : float, _prio : int = 0, _disabled : bool = false) -> TimerItem:
        return enqueue(TimerItem.new(_event, _time, _prio, _disabled))

    func poll(now : float) -> TimerItem:
        var triggered : TimerItem = null
        while triggered == null or triggered.disabled:
            if (!queue.size()) or (now < queue.back().time):
                return null
            triggered = queue.pop_back()
        triggered.trigger()
        return triggered
