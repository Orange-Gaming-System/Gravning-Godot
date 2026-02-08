@icon("res://Node Icons/node_2D/icon_gem.png")
class_name Diamond extends Collectable

func _ready():
    position = board_pos * 16
    sprite_frames = GameManager.obj_frames[Item.Type.DIAMOND]
    z_index = -1
    update_sprite()

func update_sprite():
    if map_tile.item.flags & Item.Flags.TUNNEL:
        play("tunnel")
    else:
        play("dirt")
