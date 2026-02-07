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

class Item extends RefCounted:
	enum Type {
		PLAYER    = 0x01,
		GHOST     = 0x02,
		ROCK      = 0x04,
		CLUSTER   = 0x0f,
		EMPTY     = 0x20,
		DIAMOND   = 0x2a,
		MYSTERY   = 0x3f,
		SOFTWALL  = 0xb0,
		WALL      = 0xb1,
		CHERRY    = 0xeb,
		BOMB      = 0xe5,
		AMMO      = 0xec,
		BONUS     = 0xf9,
		APPLE     = 0xfe,
		DOOR_UDL  = 0xb9,
		DOOR_UD   = 0xba,
		DOOR_DL   = 0xbb,
		DOOR_UL   = 0xbc,
		DOOR_UR   = 0xc8,
		DOOR_DR   = 0xc9,
		DOOR_ULR  = 0xca,
		DOOR_DLR  = 0xcb,
		DOOR_UDR  = 0xcc,
		DOOR_LR   = 0xcd,
		DOOR_UDLR = 0xce
	}
	enum Flags {
		NONE		= 0x00,
		BG2			= 0x01,			# Use alternate background tiles
		TUNNEL		= 0x80			# Dug tunnel
	}

	var type	: Type	= Type.EMPTY
	var flags	: Flags	= Flags.NONE

	static func is_doortype(itemtype: Type) -> bool:
		return itemtype >= Type.DOOR_UDL && itemtype <= Type.DOOR_UDLR
	func is_door() -> bool:
		return is_doortype(type)

class MapTile extends RefCounted:
	var xy		: Vector2i
	var item	: Item
	var tmr		: RandVal
	var prio	: int

var tile		: Array[MapTile]
var shuf		: Array[MapTile]
var nextshuf	: int

class RandVal extends RefCounted:
	var rand	: Rand
	var val		: float
	func _init(_rand : Rand = null, _val : float = NAN):
		rand = _rand
		val  = _val
	func intval() -> int:
		return int(val)
	const twototheminus31 = 1.0/(1 << 31);
	static func frand(mult : float = 1.0) -> float:
		# This is needed because fnrand() has inclusive
		# behavior, which is not wanted here
		return randi() * twototheminus31 * mult
	func mkrandom(level : int) -> float:
		if level < rand.minlvl:
			val = 0.0
		else:
			val = rand.valbase + (level - rand.minlvl - 1) * rand.vallvl
			if rand.valrnd:
				val += frand(rand.valrnd)
			if rand.valmax != 0.0 && val > rand.valmax:
				val = rand.valmax
			if not val >= 0.0:		# Written this way to catch NAN
				val = 0.0
		return val

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
	
	func instance():
		if (flags & RandFlags.MULTI):
			# Multi instance random
			return RandVal.new(self)
		else:
			# Single instance random
			if (!inst):
				inst = RandVal.new(self)
			return inst
	
	static func read(buf : StreamPeer) -> Rand:
		var rnd			= Rand.new()
		rnd.item		= buf.get_u8()
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
	for i in range(0, randobjs-1):
		randos.append(Rand.read(body))
		
	# Extract timers from random items list
	timers = []
	for rnd in randos:
		if (rnd.flags & Rand.RandFlags.TIMER) and (rnd.item < usedtimers):
			timers[rnd.item] = rnd
	
	# Read board (fixed items) and generate location list
	tile = []
	body.seek(boardoffset)
	for y in range(0, size.y-1):
		for x in range(0, size.x-1):
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

# Get the MapTile object at a specific coordinate
func at(xy : Vector2i) -> MapTile:
	return tile[xy.x + (xy.y * size.x)] 

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
