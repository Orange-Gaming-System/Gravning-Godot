@icon("res://Node Icons/node_2D/icon_trophy.png")
class_name Cherry extends Collectible

func collect():
    GameManager.score += GameManager.level + 1
    super.collect()
    if map_tile.map.itemcount[Item.Type.CHERRY] + map_tile.map.itemcount[Item.Type.FROZEN_CHERRY] + map_tile.map.itemcount[Item.Type.THAWED_CHERRY] <= 0:
        GameManager.load_next_level()
