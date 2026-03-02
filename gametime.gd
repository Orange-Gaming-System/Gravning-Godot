class_name GameTime extends Object

static var epoch_tick   : int
static var paused       : bool
static var pause_tick   : int

static func start() -> float:
    epoch_tick = Time.get_ticks_usec()
    pause_tick = epoch_tick
    paused = false
    return 0.0

static func now() -> float:
    var now_tick : int = pause_tick if (paused) else (Time.get_ticks_usec())
    return (now_tick - epoch_tick) * 1.0e-6

static func pause(at_time : float = NAN) -> float:
    if not paused:
        if at_time >= 0.0:         # Never true for NaN
            pause_tick = roundi(at_time * 1.0e+6) + epoch_tick
        else:
            pause_tick = Time.get_ticks_usec()
        paused = true
    return (pause_tick - epoch_tick) * 1.0e-6

static func unpause() -> float:
    var now_tick : int = Time.get_ticks_usec()
    if paused:
        epoch_tick += now_tick - pause_tick
        paused = false
    return (now_tick - epoch_tick) * 1.0e-6

static func format(when : float = now()) -> String:
    var d : int = floori(when * 10.0)
    @warning_ignore("integer_division")
    var s  : int = d / 10
    d %= 10
    @warning_ignore("integer_division")
    var m  : int = s / 60
    s %= 60
    return "%02d:%02d.%01d" % [m, s, d]
