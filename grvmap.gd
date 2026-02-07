class_name GrvMap extends RefCounted

enum GameFlags {
	ESCAPE = 0x01
}

var error			: Error
var incompatflags	: InCompatFlags	= InCompatFlags.NONE
var rocompatflags	: RoCompatFlags = RoCompatFlags.NONE
var compatflags		: CompatFlags   = CompatFlags.NONE
var size			: Vector2i
var randobjs		: int
var baselevel		: int
var gameflags		: int
var usedtimers		: int
var bombtimer		: int
var doortimer		: int
var level			: int
var player			: MapTile
var itemcount		: Array[int]

var tile			: Array[MapTile]
var shuf			: Array[MapTile]
var nextshuf		: int

var thawcount		: int
var thawlist		: Array[MapTile]

class RandVal extends RefCounted:
	var fval		: float
	var ival		: int

	static func frand(mult : float = 1.0) -> float:
		# This is needed because fnrand() has inclusive
		# behavior, which is not wanted here
		mult *= 1.0/(1 << 31)
		return randi() * mult

	func _init(rand : Rand):
		if rand.level < rand.minlvl:
			fval = 0.0
		else:
			fval = rand.valbase + (rand.level - rand.minlvl - 1) * rand.vallvl
			if rand.valrnd:
				fval += frand(rand.valrnd)
			if rand.valmax > 0.0 and fval > rand.valmax:
				fval = rand.valmax
			if not fval >= 0.0:		# Written this way to catch NAN
				fval = 0.0
		ival = floori(fval)

class Rand:
	enum RandFlags {
		ITEM		= 0x00,
		TIMER		= 0x01,
		MULTI		= 0x02,
		THAW		= 0x04
	}
	var item	# Either an Item or a Tmr
	var flags	: RandFlags	= RandFlags.ITEM
	var minlvl	: int
	var valmax	: float
	var valbase	: float
	var vallvl	: int
	var valrnd	: float
	var inst	: RandVal
	var level	: int

	func _init(_flags : RandFlags, _level : int):
		flags = _flags
		level = _level
		if (!(flags & RandFlags.MULTI)):
			inst = RandVal.new(self)

	func instance():
		if (inst):
			# Single instance random
			return inst
		else:
			# Multi instance random
			return RandVal.new(self)

	func ival():
		return instance().ival

	func fval():
		return instance().fval

	static func read(buf : StreamPeer, _level : int) -> Rand:
		var rnd_item	= buf.get_u8()
		var rnd			= Rand.new(buf.get_u8(), _level)
		rnd.item		= rnd_item
		rnd.flags		= buf.get_u8()
		rnd.minlvl		= buf.get_u16()
		rnd.valmax		= buf.get_32()
		rnd.valbase		= buf.get_double()
		rnd.vallvl		= buf.get_double()
		rnd.valrnd		= buf.get_double()
		return rnd

var timers		: Array[Rand]
var randitems	: Array[Rand]

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
enum InCompatFlags {
	NONE		= 0,
	FROZEN		= 1,
	OKMask		= 0x00000001
}
enum RoCompatFlags {
	NONE		= 0
}
enum CompatFlags {
	NONE		= 0
}

func _init(mapdata : PackedByteArray, _level : int):
	level = _level

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

	incompatflags	= body.get_u32() as InCompatFlags
	rocompatflags	= body.get_u32() as RoCompatFlags
	compatflags		= body.get_u32() as CompatFlags
	if (incompatflags & ~InCompatFlags.OKMask):
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
	randitems.clear()
	randitems.resize(Item.Type.TypeCount)
	timers.clear()
	timers.resize(usedtimers)

	body.seek(randoffset)
	for i in randobjs:
		var rnd : Rand = Rand.read(body, level)
		if rnd.minlvl >= level:
			if rnd.flags & Rand.RandFlags.TIMER:
				if rnd.item < usedtimers:
					timers[rnd.item] = rnd
			elif rnd.flags & Rand.RandFlags.THAW:
				if rnd.item == Item.Type.FROZEN_CHERRY:
					thawcount = rnd.ival()
			else:
				randitems[rnd.item] = rnd

	# Read board (fixed items) and generate shuffled list
	itemcount.clear()
	itemcount.resize(Item.Type.TypeCount)
	tile.clear()
	body.seek(boardoffset)
	for y in size.y:
		for x in size.x:
			var t : MapTile = MapTile.new(self, body.get_u8 as Item.Type, Vector2i(x, y))
			t.item.flags = body.get_u8() as Item.Flags
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

# Indicate if a specific coordinate is out of bounds
func oob(xy : Vector2i) -> bool:
	return xy.x < 0 or xy.x >= size.x or xy.y < 0 or xy.y >= size.y

# Get the MapTile object at a specific coordinate, possibly an OUT_OF_BOUNDS tile
func at(xy : Vector2i) -> MapTile:
	if oob(xy):
		return MapTile.new(self, Item.Type.OUT_OF_BOUNDS, xy)
	else:
		return tile[xy.x + (xy.y * size.x)]

# Cycle through the board locations in a random order
func randtile() -> MapTile:
	var t : MapTile = shuf[nextshuf]
	nextshuf =  wrapi(nextshuf + 1, 0, shuf.size())
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

func placerandom(type : Item.Type) -> MapTile:
	var t : MapTile = goodtile(MapTile.ok_tile(type))
	if t:
		t.changetype(type)
		if Item.type_digs_tunnel(type):
			t.dig()
	return t

# Generate the specialized the map for a specific level and add random items
func generate(hyperspace : bool):
	# Scan the tile array for:
	# 1. possible player positions, if more than one given
	# 2. frozen cherries (thaw list)
	var players : Array[MapTile]
	for t in tile:
		if t.item.type == Item.Type.PLAYER:
			players.append(t)
			t.changetype(Item.Type.EMPTY)
		elif t.item.type == Item.Type.FROZEN_CHERRY:
			thawlist.append(t)

	if players.size() == 0:
		# No player position given, pick a random player start
		player = placerandom(Item.Type.PLAYER)
	else:
		player = players[randi_range(0, players.size() - 1)]
		player.changetype(Item.Type.PLAYER)
		player.dig()

	# Place random items.
	for rnd in randitems:
		if not rnd:
			continue
		for i in rnd.ival():
			var t : MapTile = placerandom(rnd.item)
			if t and rnd.item == Item.Type.BOMB:
				t.tmr = timers[bombtimer].instance()

	# Place HYPER if applicable
	if hyperspace:
		for h in Item.Hypers:
			placerandom(h)

	# Randomize the thawlist and thaw the appropriate number of frozen cherries
	# The frozen cherries do permit organizing into priority classes, so first
	# randomize the list, then sort it by priority class
	if thawlist.size():
		thawlist.shuffle()
		thawlist.sort_custom(MapTile.by_prio)
		for i in thawcount:
			thaw()

func move_player(xy : Vector2i) -> MapTile:
	var to : MapTile = player.moveto(xy)
	if not to:
		return null			# Out of bounds
	player = to
	player.dig()
	return player

func thaw() -> MapTile:
	if thawlist.size():
		return thawlist.pop_back().change_type(Item.Type.THAWED_CHERRY)
	else:
		return null
