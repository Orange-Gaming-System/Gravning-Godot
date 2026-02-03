extends Timer

## Is used to get the value 1-time_left/wait_time. Returns a value between 0, for just started, and 1, for finished. If the timer is stopped, returns 0.
var time_ratio: float:
	get():
		return 1-time_left/wait_time
