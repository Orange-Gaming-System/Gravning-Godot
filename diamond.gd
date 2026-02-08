@icon("res://Node Icons/node_2D/icon_gem.png")
class_name Diamond extends GrvObj

func _ready():
    position = board_pos * 16
    sprite_frames = GameManager.obj_frames[Item.Type.DIAMOND]
    if map_tile.item.flags & Item.Flags.TUNNEL:
        play("tunnel")
    else:
        play("dirt")
    z_index = -1
    print("diamond")
