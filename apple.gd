@icon("res://Node Icons/node_2D/icon_tree.png")
class_name Apple extends GrvObj

const diamond_chance = 0.3

var diamond: Diamond = null

func _ready():
    super._ready()
    if randf() < diamond_chance:
        map_tile.changetype(Item.Type.APPLE_DIAMOND)
        diamond = Diamond.new(map_tile)
        GameManager.gamescene.get_node("objects").add_child.call_deferred(diamond)
    GameManager.change_move_type(board_pos, GameManager.MOVE_TYPE.BLOCKED)
