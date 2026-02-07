class_name GrvMap extends RefCounted

enum GameFlags {
	ESCAPE = 0x01
}

var error			: Error
var incompatflags	: int
var rocompatflags	: int
var compatflags		: int
var size			: Vector2i
var randobjs		: int
var baselevel		: int
var gameflags		: int
var usedtimers		: int
var bombtimer		: int
var doortimer		: int
var level			: int
var player			: MapTile

var tile		: Array[MapTile]
var shuf		: Array[MapTile]
var nextshuf	: int

class RandVal extends RefCounted:
	var rand	: Rand
	var fval	: float
	var ival	: int
	func _init(_rand : Rand):
		rand = _rand
		if rand and rand.map:
			if rand.map.level >= 0:
				mkrandom(rand.map.level)
			else:
				rand.map.randvals.append(self)
	const twototheminus31 : float = 1.0/(1 << 31);
	static func frand(mult : float = 1.0) -> float:
		# This is needed because fnrand() has inclusive
		# behavior, which is not wanted here
		return randi() * mult * twototheminus31
	func mkrandom(level : int):
		if level < rand.minlvl:
			fval = 0.0
		else:
			fval = rand.valbase + (level - rand.minlvl - 1) * rand.vallvl
			if rand.valrnd:
				fval += frand(rand.valrnd)
			if rand.valmax != 0.0 && fval > rand.valmax:
				fval = rand.valmax
			if not fval >= 0.0:		# Written this way to catch NAN
				fval = 0.0
		ival = floori(fval)

var randvals	: Array[RandVal]

class Rand:
	enum RandFlags {
		NONE		= 0x00,
		TIMER		= 0x01,
		MULTI		= 0x02
	}
	var item	# Either an Item or a Tmr
	var flags	: RandFlags	= RandFlags.NONE
	var minlvl	: int
	var valmax	: float
	var valbase	: float
	var vallvl	: int
	var valrnd	: float
	var inst	: RandVal
	var	map		: GrvMap

	func _init(_flags : RandFlags = RandFlags.NONE, _map : GrvMap = null):
		map = _map
		flags = _flags
		if (!(flags & RandFlags.MULTI)):
			inst = RandVal.new(self)

	func instance():
		if (inst):
			return inst
		else:
			# Multi instance random
			return RandVal.new(self)

	static func read(buf : StreamPeer, _map : GrvMap = null) -> Rand:
		var rnd_item	= buf.get_u8()
		var rnd			= Rand.new(buf.get_u8(), _map)
		rnd.item		= rnd_item
		rnd.flags		= buf.get_u8()
		rnd.minlvl		= buf.get_u16()
		rnd.valmax		= buf.get_32()
		rnd.valbase		= buf.get_double()
		rnd.vallvl		= buf.get_double()
		rnd.valrnd		= buf.get_double()
		return rnd

var timers		: Array[Rand]
var randos		: Array[Rand]

enum File {
	Magic		= 0x23216772760aff00,
	HdrLen		= 16
}
enum Data {
	Magic		= 0x00fd0a7672672123,
	Major		= 1,
	MaxLen		= 0x100000,
	HdrLen		= 64
}

func _init(mapdata : PackedByteArray):
	level = -1

	if mapdata.size() < File.HdrLen or mapdata.size() > Data.MaxLen:
		error = Error.ERR_FILE_CORRUPT
		return

	var hdr = StreamPeerBuffer.new()
	hdr.data_array = mapdata.slice(0, File.HdrLen)
	hdr.big_endian = true
	if hdr.get_u64() != File.Magic:
		error = Error.ERR_FILE_UNRECOGNIZED
		return

	var zsize = hdr.get_u32()
	var dsize = hdr.get_u32()
	if zsize != mapdata.size() or dsize < Data.HdrLen or dsize > Data.MaxLen:
		error = Error.ERR_FILE_CORRUPT
		return

	var body = StreamPeerBuffer.new()
	body.data_array = mapdata.slice(File.HdrLen).decompress_dynamic(dsize, 1)
	body.big_endian = false
	if body.get_size() != dsize:
		error = Error.ERR_FILE_CORRUPT
		return

	if body.get_u64() != Data.Magic or body.get_u32() != Data.Major:
		error = Error.ERR_FILE_UNRECOGNIZED
		return

	incompatflags	= body.get_u32()
	rocompatflags	= body.get_u32()
	compatflags		= body.get_u32()
	if incompatflags != 0:
		error = Error.ERR_FILE_UNRECOGNIZED
		return

	# Header length
	if (body.get_u32() < Data.HdrLen):
		error = Error.ERR_FILE_CORRUPT
		return

	var boardoffset = body.get_u32()
	var randoffset  = body.get_u32()

	size.x          = body.get_u8()
	size.y          = body.get_u8()
	randobjs        = body.get_u8()
	var timerbits   = body.get_u8()
	var timermask   = (1 << timerbits)-1

	baselevel       = body.get_u16()
	gameflags       = body.get_u16()
	if (!(rocompatflags & 0x1)):
		gameflags = 0
	usedtimers      = body.get_u8()
	bombtimer       = body.get_u8()
	doortimer       = body.get_u8()

	# Read random items list
	randos = []
	body.seek(randoffset)
	for i in randobjs:
		randos.append(Rand.read(body, self))

	# Extract timers from random items list
	timers = []
	for rnd in randos:
		if (rnd.flags & Rand.RandFlags.TIMER) and (rnd.item < usedtimers):
			timers[rnd.item] = rnd

	# Read board (fixed items) and generate location list
	tile = []
	body.seek(boardoffset)
	for y in size.y:
		for x in size.x:
			var t = MapTile.new()
			t.xy = Vector2i(x, y)
			t.item = Item.new()
			t.item.type = body.get_u8()
			t.item.flags = body.get_u8()
			var tp = body.get_u16()
			t.prio = tp >> timerbits
			tp &= timermask
			if t.prio and tp < usedtimers:
				t.tmr = timers[tp & timermask].instance()
			tile.append(t)
	shuf = tile.duplicate()
	shuf.shuffle()
	nextshuf = 0

	error = Error.OK
	return

# Generate an out-of-bounds MapTile object
func oobtile(xy : Vector2i) -> MapTile:
	var t : MapTile = MapTile.new()
	t.item			= Item.new()
	t.xy			= xy
	t.item.type		= Item.Type.OUT_OF_BOUNDS
	t.item.flags	= Item.Flags.NONE
	t.prio			= 0
	t.tmr			= null
	return t

# Get the MapTile object at a specific coordinate
func at(xy : Vector2i) -> MapTile:
	if xy.x >= 0 and xy.x < size.x and xy.y >= 0 and xy.y < size.y:
		return tile[xy.x + (xy.y * size.x)]
	else:
		return oobtile(xy)

# Cycle through the board locations in a random order
func randtile() -> MapTile:
	var t : MapTile = shuf[nextshuf]
	nextshuf = (nextshuf + 1) % shuf.size()
	return t

# Cycle through the board locations in random order, until one is
# found for which the user-specified functions returns true
# Returns null if every spot on the board was tried unsuccessfully
func goodtile(is_good : Callable) -> MapTile:
	var start : int = nextshuf
	var here : MapTile	= randtile()
	while not is_good.call(here):
		if nextshuf == start:
			return null
		here = randtile()
	return here

func below(t : MapTile) -> MapTile:
	return at(t.xy + Vector2i(0,1))
func above(t : MapTile) -> MapTile:
	return at(t.xy + Vector2i(0,-1))

func empty_tile(t : MapTile) -> bool:
	return t.item.type == Item.Type.EMPTY

func dirt_tile(t : MapTile) -> bool:
	return t.item.is_dirt()

func dirt_2tiles(t : MapTile) -> bool:
	return t.item.is_dirt() and below(t).item.is_dirt()

# Generate the specialized the map for a specific level and add random items
func generate(_level : int, hyperspace : bool):
	level = _level

	# Now the level is defined, assign numeric values to all random instances
	for rv in randvals:
		rv.mkrandom(level)
	randvals = []

	# Select player position, if more than one given
	var players : Array[MapTile] = []
	for t in tile:
		if t.item.type == Item.Type.PLAYER:
			players.append(t)
			t.item.type = Item.Type.EMPTY
	if players.size() == 0:
		# No player position given, pick a random player start
		players.append(goodtile(empty_tile))
	player = players[randi_range(0, players.size() - 1)]
	player.item.type = Item.Type.PLAYER

	# Place random items
	for rnd in randos:
		if (!(rnd.flags & Rand.RandFlags.TIMER)):
			for i in rnd.instance().ival:
				var t : MapTile
				if rnd.item == Item.Type.APPLE:
					t = goodtile(dirt_2tiles)
				else:
					t = goodtile(dirt_tile)
				if not t:
					return
				t.item.type = rnd.item
				if rnd.item == Item.Type.BOMB:
					t.tmr = timers[bombtimer].instance()

	# Place HYPER if applicable
	if hyperspace:
		for h in Item.Hypers:
			var t : MapTile = goodtile(dirt_tile)
			if not t:
				return
			t.item.type = h
