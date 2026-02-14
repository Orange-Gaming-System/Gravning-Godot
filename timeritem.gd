class_name TimerItem extends RefCounted

var time        : float
var prio        : int
var event       : Callable

func _init(_event : Callable, _time : float, _prio : int = 0):
    event = _event
    time = _time
    prio = _prio

# Return a true value to indicate that this event is the "real" event for
# this run; return a false value to pop another entry off the queue.
func trigger():
    return event.call(self)

# Dummy trigger event
static func _deleted_event(_tmr : TimerItem) -> bool:
    return false

## Disable a pending timer event. The [method poll] function will remove it from
## the queue later without returning.
func disable() -> void:
    event = _deleted_event

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

    func add(_event : Callable, _time : float, _prio : int = 0) -> TimerItem:
        return enqueue(TimerItem.new(_event, _time, _prio))

    func poll(now : float) -> TimerItem:
        var triggered : TimerItem = null
        while triggered == null:
            if queue.is_empty() or now < queue.back().time:
                return null
            triggered = queue.pop_back()
            if !triggered.trigger():
                triggered = null
        return triggered
