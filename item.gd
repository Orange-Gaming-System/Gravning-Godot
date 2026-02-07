class_name Item extends RefCounted
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
	NONE			= 0x00,
	BG2			= 0x01,			# Use alternate background tiles
	TUNNEL		= 0x80			# Dug tunnel
}

var type		: Type	= Type.EMPTY
var flags	: Flags	= Flags.NONE

static func is_doortype(itemtype: Type) -> bool:
	return itemtype >= Type.DOOR_UDL && itemtype <= Type.DOOR_UDLR
func is_door() -> bool:
	return is_doortype(type)
