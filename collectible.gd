@icon("res://Node Icons/node_2D/icon_coin.png")
class_name Collectible extends GrvObj


func collect():
    map_tile.rmv_obj()
