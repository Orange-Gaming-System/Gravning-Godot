class_name MapTile extends RefCounted
var xy			: Vector2i
var item		: Item
var tmr			: GrvMap.RandVal
var prio		: int
var map			: GrvMap
var node			: GrvObj

func _init(_map : GrvMap = null, _type : Item.Type = Item.Type.NONE, _xy : Vector2i = Vector2i(-1, -1)):
	map = _map
	xy = _xy
	item = Item.new()
	item.type = _type
	if map:
		map.itemcount[item.type] += 1

func _notification(what : int):
	if what == NOTIFICATION_PREDELETE and map:
		map.itemcount[item.type] -= 1

# Change the type of a tile, updating the item count in the map
func changetype(type : Item.Type) -> MapTile:
	if map:
		map.itemcount[item.type] -= 1
		item.type = type
		map.itemcount[item.type] += 1
	else:
		item.type = type
	return self

# Move a tile type to a different spot in the map, leaving an EMPTY tile
# Returns the new tile, or null if either the old or new position was
# out of bounds. It does not change the item flags.
func moveto(toxy : Vector2i) -> MapTile:
	if not map or oob():
		return null
	var to : MapTile = map.at(toxy)
	if to.oob():
		return null
	to.changetype(item.type)
	changetype(Item.Type.EMPTY)
	return to

# Indicate if it is valid to move this tile from the current location to another.
# Returns the target tile if valid, or null if invalid.
func can_move_to(toxy : Vector2i) -> MapTile:
	if not map or oob():
		return null
	var to : MapTile = map.at(toxy)
	if to.oob():
		return null
	var ok : bool = false
	if item.type == Item.Type.PLAYER:
		ok = to.player_can_eat()
	elif item.type == Item.Type.GHOST:
		ok = to.is_tunnel()
	else:
		ok = to.is_dirt()
	return (to) if (ok) else null

# Sets the tunnel flag. Does not change the item type.
func dig() -> MapTile:
	@warning_ignore("int_as_enum_without_cast")
	item.flags |= Item.Flags.TUNNEL
	return self

# Getting an adjacent tile by relative coordinates
func dv(v : Vector2i) -> MapTile:
	return map.at(xy + v)
func dxy(x : int, y : int) -> MapTile:
	return dv(Vector2i(x,y))

func below() -> MapTile:
	return dxy(0, 1)
func above() -> MapTile:
	return dxy(0, -1)
func left() -> MapTile:
	return dxy(-1, 0)
func right() -> MapTile:
	return dxy(1, 0)

# Tile out of bounds?
func oob() -> bool:
	return item.type == Item.Type.OUT_OF_BOUNDS

# Predicates for use with GrvMap.goodtile()
static func any_tile(_t : MapTile) -> bool:
	return true

static func empty_tile(t : MapTile) -> bool:
	return t.item.type == Item.Type.EMPTY

static func dirt_tile(t : MapTile) -> bool:
	return t.item.is_dirt()

static func dirt_2tiles(t : MapTile) -> bool:
	return t.item.is_dirt() and t.below().item.is_dirt()

static func tunnel_tile(t : MapTile) -> bool:
	return t.item.is_tunnel()

# Get the correct predicate for a certain tile type
static func ok_tile(type : Item.Type) -> Callable:
	if Item.type_needs_dirt_below(type):
		return dirt_2tiles
	elif type == Item.Type.PLAYER:
		return empty_tile
	elif Item.type_needs_tunnel(type):
		return tunnel_tile
	else:
		return dirt_tile

# Sorting functions
static func by_prio(a : MapTile, b : MapTile) -> bool:
	return a.item.prio < b.item.prio

## Spawns an object from a [MapTile]. The provided [MapTile] must not be a door, wall, soft wall, or empty.
func spawn_obj():
	var obj_node = LevelBuilder.obj_classes[item.type].new(self)
	GameManager.gamescene.get_node("objects").add_child(obj_node)
	node = obj_node

func rmv_obj():
	changetype(Item.Type.EMPTY)
	node.queue_free()
	node = null
