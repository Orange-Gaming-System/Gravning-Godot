class_name Item extends RefCounted

enum Type {
    NONE                =  0x00,    # Invalid type

    # Item types that can appear in a .grvmap file
    PLAYER              =  0x01,
    GHOST               =  0x02,
    ROCK                =  0x04,
    CLUSTER             =  0x0f,
    EMPTY               =  0x20,
    DIAMOND             =  0x2a,
    MYSTERY             =  0x3f,
    SOFTWALL            =  0xb0,
    WALL                =  0xb1,
    CHERRY              =  0xeb,
    FROZEN_CHERRY       =  0xef,
    BOMB                =  0xe5,
    AMMO                =  0xec,
    BONUS               =  0xf9,
    APPLE               =  0xfe,

    # Item types only used internally
    OUT_OF_BOUNDS       = 0x100,
    HYPER               = 0x101,
    THAWED_CHERRY       = 0x102,
    APPLE_DIAMOND       = 0x103,
    DOOR                = 0x104,

    # End sentinel
    TypeCount                   # One more than the highest enum value
}
enum Flags {
    NONE        = 0x00,
    BG2         = 0x01,         # Use alternate background tiles
    TUNNEL      = 0x80,         # Dug tunnel
    TUNNEL_BG2	= 0x81			# For the benefit of the editor
}

# This enumeration is also a bitmap
enum Door {
    # GONE Door
    GONE    = 0,
    # More Door
    R, L, LR,
    D, DR, DL, DLR,
    U, UR, UL, ULR,
    UD, UDR, UDL, UDLR,
}

const doorways : Dictionary[int, int] = {
    0xb9    : Door.UDL,
    0xba    : Door.UD,
    0xbb    : Door.DL,
    0xbc    : Door.UL,
    0xc8    : Door.UR,
    0xc9    : Door.DR,
    0xca    : Door.ULR,
    0xcb    : Door.DLR,
    0xcc    : Door.UDR,
    0xcd    : Door.LR,
    0xce    : Door.UDLR
}

const visuals : Dictionary[Type, Array] = {
    Type.DOOR   : [ "", "R", "L", "LR", "D", "DR", "DL", "DLR",
                    "U", "UR", "UL", "ULR", "UD", "UDR", "UDL", "UDLR" ],
    Type.HYPER  : [ "H", "Y", "P", "E", "R"]
}

@export var type    : Type  = Type.EMPTY
@export var visual  : int
@export var flags   : Flags = Flags.NONE

func visual_str() -> String:
    if visuals.has(type):
        var viz : Array = visuals[type]
        if visual < viz.size():
            return viz[visual]
    return ""

# Delete these functions eventually
static func is_doortype(itemtype: Type) -> bool:
    return itemtype == Type.DOOR
func is_door() -> bool:
    return is_doortype(type)

# Delete these functions eventually
static func is_hypertype(itemtype : Type) -> bool:
    return itemtype == Type.HYPER
func is_hyper() -> bool:
    return is_hypertype(type)

# When placed at game start, MUST be in an already dug tunnel
static func type_needs_tunnel(itemtype : Type) -> bool:
    return itemtype == Type.GHOST

# When placed at game start, (not moving!) DIG a tunnel
static func type_digs_tunnel(itemtype : Type) -> bool:
    return itemtype == Type.PLAYER or itemtype == Type.ROCK

func in_tunnel() -> bool:
    return flags & Flags.TUNNEL

func is_dirt() -> bool:
    return type == Type.EMPTY and not in_tunnel()

func is_tunnel() -> bool:
    return type == Type.EMPTY and in_tunnel()

static func type_is_apple(itemtype : Type) -> bool:
    return itemtype == Type.APPLE or itemtype == Type.APPLE_DIAMOND
func is_apple() -> bool:
    return type_is_apple(type)

# An edible cherry (not frozen)
func is_cherry() -> bool:
    return type == Type.CHERRY or type == Type.THAWED_CHERRY

# Can the player move to a tile occupied by an object of this type?
# It doesn't mean it is safe to do so!
func player_can_eat() -> bool:
    return type == Type.EMPTY or is_cherry() or type == Type.GHOST or type == Type.SOFTWALL or \
        type == Type.DIAMOND or type == Type.AMMO or type == Type.BONUS or type == Type.MYSTERY or is_hyper()
