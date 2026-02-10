class_name TimerItem extends RefCounted

var time        : float
var prio        : int
var event       : Callable
var disabled    : bool

## This queue is sorted in order of [i]decreasing[/i] time; the next event is at the end
## This ordering is more efficient than the other way around.
static var queue : Array[TimerItem]

# The corresponding sort/bsearch function
static func run_after(a : TimerItem, b : TimerItem) -> bool:
    if a.time != b.time:
        return a.time > b.time
    else:
        return a.prio > b.prio

func _init(_event : Callable, _time : float, _prio : int = 0):
    event = _event
    time = _time
    prio = _prio
    disabled = false
    queue.insert(queue.bsearch_custom(queue, run_after, true), self)

static func clearall():
    queue.clear()

func trigger() -> void:
    event.call(self)

## Disable a pending timer event. The [method poll] function will remove it from
## the queue later.
func disable(off : bool = true):
    disabled = off

static func poll(now : float) -> TimerItem:
    var triggered : TimerItem = null
    while triggered == null or triggered.disabled:
        if (!queue.size()) or (now < queue.back().time):
            return null
        triggered = queue.pop_back()
    triggered.trigger()
    return triggered
