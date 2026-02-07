class_name GameTime extends Object

static var epoch_tick	: int
static var paused		: bool
static var pause_tick	: int

static func start() -> float:
	epoch_tick = Time.get_ticks_usec()
	pause_tick = epoch_tick
	return 0.0
	
static func now() -> float:
	var now_tick : int = pause_tick if (paused) else (Time.get_ticks_usec())
	return (now_tick - epoch_tick) * 1.0e-6

static func pause() -> float:
	if not paused:
		pause_tick = Time.get_ticks_usec()
		paused = true
	return (pause_tick - epoch_tick) * 1.0e-6

static func unpause() -> float:
	var now_tick : int = Time.get_ticks_usec()
	if paused:
		epoch_tick += now_tick - pause_tick
		paused = false
	return (now_tick - epoch_tick) * 1.0e-6
