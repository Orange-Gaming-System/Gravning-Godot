@icon("res://Node Icons/node_2D/icon_tree.png")
class_name Apple extends GrvObj

const diamond_chance = 0.3

func _init(tile: MapTile):
    super._init(tile)
    if randf() < diamond_chance:
        tile.changetype(Item.Type.APPLE_DIAMOND)
