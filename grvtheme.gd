class_name GrvTheme extends Resource

## Stores the data for a Grävning theme.
##
## This class includes all the root data for a Grävning Theme alongside all the code necessary to load one in.

## The name of the theme. This is not an ID, just a display name.
@export var name: String

## A description of the theme.
@export var description: String

var theme: Theme

var cheat_theme: Theme

var tileset: TileSet

var lives_sprite: Texture

var cave_bg: Texture

var status_frame: Texture

const obj_frame_paths: Dictionary[Item.Type, String] = {Item.Type.CHERRY: "objects/cherry.tres", Item.Type.AMMO: "objects/ammo.tres", Item.Type.PLAYER: "objects/player.tres", Item.Type.APPLE: "objects/apple.tres", Item.Type.DIAMOND: "objects/diamond.tres", Item.Type.GHOST: "objects/ghost.tres", Item.Type.FROZEN_CHERRY: "objects/frozen_cherry.tres", Item.Type.THAWED_CHERRY: "objects/thawed_cherry.tres", Item.Type.BONUS: "objects/bonus_coin.tres", Item.Type.DOOR: "objects/doors.tres", Item.Type.HYPER: "objects/hyper.tres", Item.Type.ROCK: "objects/rock.tres", Item.Type.BOMB: "objects/bomb.tres", Item.Type.MYSTERY: "objects/mystery.tres", Item.Type.CLUSTER: "objects/cluster_bomb.tres", Item.Type.EASTER_EGG: "objects/easter_egg.tres"}

var obj_frames: Dictionary[Item.Type, SpriteFrames] = {}

const other_frame_paths: Dictionary[String, String] = {"bullet": "objects/bullets.tres", "falling_apple": "objects/falling_apple.tres"}

var other_frames: Dictionary[String, SpriteFrames] = {"bullet": preload("res://themes/default/objects/bullets.tres"), "falling_apple": preload("res://themes/default/objects/apple.tres")}


## Loads in the theme.
func load_theme():
    theme = load_theme_item("theme.tres")
    cheat_theme = load_theme_item("cheat_theme.tres")
    tileset = load_theme_item("tileset.tres")
    lives_sprite = load_theme_item("lives_sprite.png")
    cave_bg = load_theme_item("cave_bg.png")
    status_frame = load_theme_item("status_frame.png")
    # Load object frames.
    for obj in obj_frame_paths:
        var obj_path = obj_frame_paths[obj]
        obj_frames[obj] = load_theme_item(obj_path)
    # Load other frames.
    for item in other_frame_paths:
        var item_path = other_frame_paths[item]
        other_frames[item] = load_theme_item(item_path)
    GameManager.audio.load_sound_data(resource_path.get_base_dir() + "/sound/")
    return self

## Gets a single theme item (using [method @GDScript.load]) from a relative path. If the item does not exist, loads from the default theme instead.
func load_theme_item(path: String) -> Resource:
    var full_path = resource_path.get_base_dir() + "/" + path
    if FileAccess.file_exists(full_path):
        return load(full_path)
    else:
        return load("res://themes/default/" + path)
