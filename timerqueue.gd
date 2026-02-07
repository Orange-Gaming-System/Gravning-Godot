class_name TimerQueue extends RefCounted

class TimerItem	extends RefCounted:
	var time	: float
	var	prio	: int
	static func after(a : TimerItem, b : TimerItem) -> bool:
		if a.time != b.time:
			return a.time > b.time
		else:
			return a.prio > b.prio

# This queue is sorted in order of *decreasing* time; the next event is at the end
var queue : Array[TimerItem]

func insert(tmr : TimerItem):
	queue.insert(queue.bsearch_custom(tmr, TimerItem.after, true), tmr)

func poll(now : float):
	if (!queue.size()) or (now < queue.back().time):
		return null
	return queue.pop_back()
