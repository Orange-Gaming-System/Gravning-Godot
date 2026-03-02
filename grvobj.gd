@icon("res://Node Icons/node_2D/icon_crate.png")
class_name GrvObj extends AnimatedSprite2D

## Holds the current player position in tiles. Is floating point to avoid snappy movement.
@export var board_pos: Vector2

## Holds the [MapTile] originally used to spawn the object, or null if this
## object is pending deletion.
var map_tile: MapTile

func _ready():
    position = board_pos * 16
    sprite_frames = GameManager.obj_frames[map_tile.item.type]
    if sprite_frames.has_animation("default"):
        play("default")
    GameManager.game_clock.timeout.connect(_maybe_new_tick)

func delete() -> void:
    stop()
    visible = false
    map_tile = null
    queue_free()

func _init(tile: MapTile):
    board_pos = tile.xy
    map_tile = tile

func _maybe_new_tick():
    if map_tile:
        _new_tick()

func _new_tick():
    pass

func hit_by_rock():
    map_tile.rmv_obj()

func bombed():
    map_tile.rmv_obj()

func hit_by_bullet(_movement):
    map_tile.rmv_obj()

## Creates an [AudioStreamPlayer2D] to play a sound specified in [param sound_name]. Returns the [AudioStreamPlayer2D] and stores it in [member last_audio].
func create_audio_player(sound_name: String) -> AudioStreamPlayer2D:
    var audio = AudioStreamPlayer2D.new()
    audio.stream = GameManager.audio.sound_data[sound_name]
    add_child(audio)
    return audio
