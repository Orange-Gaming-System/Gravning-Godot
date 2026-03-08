extends Node2D

var objects     : Node2D
var end_timer   : Timer

func _ready():
    objects = get_node("objects")
    end_timer = get_node("end_timer")
    end_timer.stop()
    GameManager.start_game()
    # Handle theme data.
    $BG.texture = GameManager.grvtheme.cave_bg
    $UI/lives.texture = GameManager.grvtheme.lives_sprite
    %ground_tiles.tile_set = GameManager.grvtheme.tileset
    $UI/hyper_H.sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.HYPER]
    $UI/hyper_Y.sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.HYPER]
    $UI/hyper_P.sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.HYPER]
    $UI/hyper_E.sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.HYPER]
    $UI/hyper_R.sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.HYPER]
    $ending/gameover.texture = GameManager.grvtheme.status_frame
