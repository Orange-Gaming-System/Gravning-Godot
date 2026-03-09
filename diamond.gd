@icon("res://Node Icons/node_2D/icon_gem.png")
class_name Diamond extends Collectible

const EASTER_EGG_CHANCE = 0.003

func _ready():
    position = board_pos * 16
    if randf() < EASTER_EGG_CHANCE:
        map_tile.changetype(Item.Type.APPLE_EASTER)
        sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.EASTER_EGG]
    else:
        sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.DIAMOND]
    z_index = -1
    update_sprite()

func update_sprite():
    if !(sprite_frames.has_animation("tunnel") and sprite_frames.has_animation("dirt")):
        return
    if map_tile.item.flags & Item.Flags.TUNNEL:
        play("tunnel")
    else:
        play("dirt")

func collect():
    if map_tile.item.type == Item.Type.EASTER_EGG:
        # Calculate score target (equivalent to 3 Diamonds)
        GameManager.bonus_spin_target = int((GameManager.level * (80.0 + exp(randf() * 6.0))) + 100) + int((GameManager.level * (80.0 + exp(randf() * 6.0))) + 100) + int((GameManager.level * (80.0 + exp(randf() * 6.0))) + 100)

        GameManager.bonus_spin_ctr    = 0
        GameManager.bonus_spin_step   = roundi(GameManager.bonus_spin_target / GameManager.BONUS_SPIN_TIME)
    else:
        GameManager.score += int((GameManager.level * (80.0 + exp(randf() * 6.0))) + 100)
    super.collect()
