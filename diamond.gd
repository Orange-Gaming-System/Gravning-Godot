@icon("res://Node Icons/node_2D/icon_gem.png")
class_name Diamond extends Collectible

const EASTER_EGG_CHANCE = 1 # 0.003

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
    GameManager.score += int((GameManager.level * (80.0 + exp(randf() * 6.0))) + 100)
    if map_tile.item.type == Item.Type.EASTER_EGG:
        GameManager.game_clock.timeout.connect.call_deferred(send_to_secret)
    else:
        super.collect()

func send_to_secret():
    var give_hyper = false
    if GameManager.grvmap.itemcount[Item.Type.HYPER] > 0 or GameManager.hyper.has(true):
        give_hyper = true
    GameManager.is_easter_egg_level = true
    GameManager.load_next_level(0)
    if give_hyper:
        GameManager.hyper = [true, true, true, true, true]
