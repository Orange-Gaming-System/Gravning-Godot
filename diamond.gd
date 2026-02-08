@icon("res://Node Icons/node_2D/icon_gem.png")
class_name Diamond extends Collectible

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

func collect():
    GameManager.score += int((GameManager.level * (80.0 + exp(randf() * 6.0))) + 100)
    super.collect()
