class_name MapTile extends RefCounted
var xy          : Vector2i
var item        : Item
var tmr         : GrvMap.RandVal
var prio        : int
var map:
    get:
        return map.get_ref()
var node        : GrvObj

func _init(_map : GrvMap = null, _type : Item.Type = Item.Type.NONE, _xy : Vector2i = Vector2i(-1, -1)):
    map = weakref(_map)
    xy = _xy
    item = Item.new()
    if map and map.oob(xy):
        _type = Item.Type.OUT_OF_BOUNDS
    elif _type == Item.Type.OUT_OF_BOUNDS:
        _type = Item.Type.NONE
    elif _type == Item.Type.ROCK:
        item.visual = randi_range(0, 7)
    elif Item.doorways.has(_type):
        item.visual = Item.doorways[_type]
        _type = Item.Type.DOOR
    item.type = _type
    remember()

func remember() -> void:
    if map and not oob():
        map.itemcount[item.type] += 1
        map.items[item.type][xy] = self

func forget() -> void:
    if map and not oob():
        map.itemcount[item.type] -= 1
        map.items[item.type].erase(xy)

func _notification(what : int):
    if self:
        if what == NOTIFICATION_PREDELETE:
            forget()

# Change the type of a tile, updating the item count in the map
func changetype(type : Item.Type) -> MapTile:
    if type != item.type and not oob():
        forget()
        item.type = type
        remember()
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
    to.item.visual = item.visual
    to.node = node
    if toxy != xy:
        changetype(Item.Type.EMPTY)
        node = null
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
        ok = to.is_tunnel() or to.item.type == Item.Type.PLAYER
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

static func dirt_dirt_below_tile(t : MapTile) -> bool:
    return t.item.is_dirt() and t.below().item.is_dirt()

# A ghost must be placed in a tunnel, and not underneath a rock
static func ghost_ok_tile(t : MapTile) -> bool:
    return t.is_tunnel() and not t.above().item.type == Item.Type.ROCK

# At the start of the game, don't place the player immediately next to a ghost
func is_next_to_ghost() -> bool:
    return  (above().item.type == Item.Type.GHOST or
             below().item.type == Item.Type.GHOST or
             left().item.type  == Item.Type.GHOST or
             right().item.type == Item.Type.GHOST)

# Get the correct predicate for a certain tile type. This does not support
# Item.Type.PLAYER.
static func ok_tile(type : Item.Type) -> Callable:
    if (type == Item.Type.APPLE or type == Item.Type.APPLE_DIAMOND or
        type == Item.Type.ROCK):
        return dirt_dirt_below_tile
    elif type == Item.Type.GHOST:
        return ghost_ok_tile
    else:
        return dirt_tile

# Sorting functions
static func by_prio(a : MapTile, b : MapTile) -> bool:
    return a.prio < b.prio

func player_start_prio() -> int:
    var sp : int = 0
    if item.type != Item.Type.EMPTY:
        sp += 0x4000000         # Really really bad
    if is_next_to_ghost():
        sp += 0x10000           # Avoid next to ghost
    if not item.in_tunnel():
        sp += 0x100             # Prefer an already dug tunnel
    return sp

static func by_player_start_prio(a : MapTile, b : MapTile) -> bool:
    return a.player_start_prio() < b.player_start_prio()

## Spawns an object from a [MapTile]. The provided [MapTile] must not be a door, wall, soft wall, or empty.
func spawn_obj():
    var obj_node = LevelBuilder.obj_classes[item.type].new(self)
    GameManager.gamescene.get_node("objects").add_child(obj_node)
    node = obj_node

func rmv_obj():
    changetype(Item.Type.EMPTY)
    node.queue_free()
    node = null
