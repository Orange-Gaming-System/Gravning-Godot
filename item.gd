class_name Item extends RefCounted
enum Type {
	NONE			= 0x00,		# Invalid type
	PLAYER			= 0x01,
	GHOST			= 0x02,
	ROCK			= 0x04,
	CLUSTER			= 0x0f,
	EMPTY			= 0x20,
	DIAMOND			= 0x2a,
	MYSTERY			= 0x3f,
	SOFTWALL		= 0xb0,
	WALL			= 0xb1,
	CHERRY			= 0xeb,
	FROZEN_CHERRY	= 0xef,
	BOMB			= 0xe5,
	AMMO			= 0xec,
	BONUS			= 0xf9,
	APPLE			= 0xfe,
	DOOR_UDL		= 0xb9,
	DOOR_UD			= 0xba,
	DOOR_DL			= 0xbb,
	DOOR_UL			= 0xbc,
	DOOR_UR			= 0xc8,
	DOOR_DR			= 0xc9,
	DOOR_ULR		= 0xca,
	DOOR_DLR		= 0xcb,
	DOOR_UDR		= 0xcc,
	DOOR_LR			= 0xcd,
	DOOR_UDLR		= 0xce,
	OUT_OF_BOUNDS	= 0x100,
	HYP_H			= 0x101,
	HYP_Y			= 0x102,
	HYP_P			= 0x103,
	HYP_E			= 0x104,
	HYP_R			= 0x105,
	THAWED_CHERRY	= 0x106,
	TypeCount					# One more than the highest enum value
}
enum Flags {
	NONE		= 0x00,
	BG2			= 0x01,			# Use alternate background tiles
	TUNNEL		= 0x80			# Dug tunnel
}
const Hypers : Array[Type] = [Type.HYP_H, Type.HYP_Y, Type.HYP_P, Type.HYP_E, Type.HYP_R]

var type	: Type	= Type.EMPTY
var flags	: Flags	= Flags.NONE

static func is_doortype(itemtype: Type) -> bool:
	return itemtype >= Type.DOOR_UDL and itemtype <= Type.DOOR_UDLR
func is_door() -> bool:
	return is_doortype(type)

static func is_hypertype(itemtype : Type) -> bool:
	return itemtype >= Type.HYP_H and itemtype <= Type.HYP_R
func is_hyper() -> bool:
	return is_hypertype(type)

static func type_needs_dirt_below(itemtype : Type) -> bool:
	return itemtype == Type.APPLE or itemtype == Type.ROCK

func is_dirt() -> bool:
	return type == Type.EMPTY and !(flags & Flags.TUNNEL)
