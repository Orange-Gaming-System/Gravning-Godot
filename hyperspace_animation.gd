extends Node3D

## The speed of each object. If negative, objects fly away from the camera, if positive, they fly towards the camera. This is in m/s.
var object_speed: float
## The z-position objects spawn at.
var object_spawn: float
## The z-position objects destroy themselves at. Note: They will still destroy themselves if they go past this position.
var object_destroy: float

## All the levels that objects will be pulled from.
var levels: Array[int]

## All the objects that need to be spawned. This array should be in the order the levels will show up.
var objects: Array[MapTile]

## The total time, in seconds that the animation should take.
var time: float

## The objects not allowed to be included.
const blacklisted_objects = [Item.Type.PLAYER, Item.Type.EMPTY, Item.Type.WALL, Item.Type.SOFTWALL]

var last_level_grvmap: GrvMap = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    GameManager.game_clock = $fake_game_clock
    objects = []
    levels.reverse()
    for level in levels:
        var map = Map.new(GameManager.grv_file.get_level_path(level))
        if !last_level_grvmap:
            last_level_grvmap = map.grvmap
        var lvl_objs: Array[MapTile]
        for object in map.objs:
            if !object.item.type in blacklisted_objects:
                lvl_objs.append(object)
        lvl_objs.shuffle()
        objects.append_array(lvl_objs)
    var spawn_rate = time / objects.size()

    # Setup Audio

    $audio_start.stream = GameManager.audio.sound_data.hs_start

    var loop = AudioStreamPlaylist.new()
    loop.stream_count += 1
    loop.set_list_stream(0, GameManager.audio.sound_data.hs_loop)
    $audio_loop.stream = loop

    $audio_end.stream = GameManager.audio.sound_data.hs_end


    _on_obj_spawn_timer_timeout()
    $obj_spawn_timer.start(spawn_rate)
    $audio_start.play()


func _on_obj_spawn_timer_timeout() -> void:
    var object = objects.pop_back()
    if !object:
        object = last_level_grvmap.player
        $obj_spawn_timer.stop()
        $audio_loop.stream.loop = false
    var grv_obj = LevelBuilder.obj_classes[object.item.type].new(object)
    add_child(grv_obj)
    var anim_obj = HyperspaceAnimationObject.new()
    anim_obj.pixel_size = 0.03125
    anim_obj.position = Vector3(randf_range(-2, 2), randf_range(-2, 2), object_spawn)
    anim_obj.sprite_frames = grv_obj.sprite_frames
    anim_obj.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
    anim_obj.play(grv_obj.animation)
    grv_obj.free()
    add_child(anim_obj)


func _on_audio_finished() -> void:
    GameManager.is_wraparound = true
    GameManager.prepare_game()
    queue_free()
