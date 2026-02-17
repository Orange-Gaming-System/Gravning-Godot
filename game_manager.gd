@icon("res://Node Icons/node/icon_brain.png")
class_name Game_Manager extends Node

## Holds the current level number - 1. Should never be greater than or equal to [member grv_File_Loader.levelcount].
var level: int = 0:
    set(value):
        level = value
        gamescene.get_node("UI/level").text = str(level + 1)

## Holds the number of levels the player has beaten since they died or HYPER appeared. If it is 4 or greater when loading a level, HYPER is spawned.
var level_streak: int = 0

var has_lost_level: bool = false

var lives: int = 3

## Holds the current score. Can be negative!
var score: int = 0:
    set(value):
        score = value
        gamescene.get_node("UI/score").text = str(score)

## The amount of ammo the play has.
var ammo: int = 0:
    set(value):
        ammo = value
        if value > 99:
            ammo = 99
        gamescene.get_node("UI/ammo").visible = ammo
        gamescene.get_node("UI/Fixed/ammo").visible = ammo
        gamescene.get_node("UI/ammo").text = str(ammo)

## Holds whether or not bonus dots will give score right now.
var bonus: bool = false

var hyper: Array[bool] = [false, false, false, false, false]

var game_clock: Timer

## Holds a reference to the current active cheat menu (or null if nonexistent).
var chmenu: Window

const obj_frames: Dictionary[Item.Type, SpriteFrames] = {Item.Type.CHERRY: preload("res://themes/default/objects/cherry.tres"), Item.Type.AMMO: preload("res://themes/default/objects/ammo.tres"), Item.Type.PLAYER: preload("res://themes/default/objects/player.tres"), Item.Type.APPLE: preload("res://themes/default/objects/apple.tres"), Item.Type.DIAMOND: preload("res://themes/default/objects/diamond.tres"), Item.Type.GHOST: preload("res://themes/default/objects/ghost.tres"), Item.Type.FROZEN_CHERRY: preload("res://themes/default/objects/frozen_cherry.tres"), Item.Type.THAWED_CHERRY: preload("res://themes/default/objects/thawed_cherry.tres"), Item.Type.BONUS: preload("res://themes/default/objects/bonus_coin.tres"), Item.Type.DOOR: preload("res://themes/default/objects/doors.tres"), Item.Type.HYPER: preload("res://themes/default/objects/hyper.tres"), Item.Type.ROCK: preload("res://themes/default/objects/rock.tres"), Item.Type.BOMB: preload("res://themes/default/objects/bomb.tres"), Item.Type.MYSTERY: preload("res://themes/default/objects/mystery.tres"), Item.Type.CLUSTER: preload("res://themes/default/objects/cluster_bomb.tres")}

const bomb_actions: Dictionary[Item.Type, BombAction] = {Item.Type.CHERRY: BombAction.COLLECT, Item.Type.AMMO: BombAction.DESTROY, Item.Type.PLAYER: BombAction.OTHER, Item.Type.APPLE: BombAction.NONE, Item.Type.DIAMOND: BombAction.DESTROY, Item.Type.GHOST: BombAction.DESTROY, Item.Type.FROZEN_CHERRY: BombAction.NONE, Item.Type.THAWED_CHERRY: BombAction.COLLECT, Item.Type.BONUS: BombAction.OTHER, Item.Type.DOOR: BombAction.NONE, Item.Type.HYPER: BombAction.NONE, Item.Type.ROCK: BombAction.NONE, Item.Type.BOMB: BombAction.NONE, Item.Type.WALL: BombAction.DESTROY, Item.Type.SOFTWALL: BombAction.DESTROY, Item.Type.EMPTY: BombAction.NONE, Item.Type.MYSTERY: BombAction.DESTROY, Item.Type.CLUSTER: BombAction.NONE, Item.Type.APPLE_DIAMOND: BombAction.NONE}

enum BombAction {
    NONE,
    COLLECT,
    DESTROY,
    OTHER
}

const bullet_effects: Dictionary[Item.Type, BulletEffect] = {Item.Type.CHERRY: BulletEffect.COLLECT, Item.Type.AMMO: BulletEffect.COLLECT, Item.Type.PLAYER: BulletEffect.OTHER, Item.Type.APPLE: BulletEffect.BLOCK, Item.Type.DIAMOND: BulletEffect.COLLECT, Item.Type.GHOST: BulletEffect.DESTROY, Item.Type.FROZEN_CHERRY: BulletEffect.BLOCK, Item.Type.THAWED_CHERRY: BulletEffect.COLLECT, Item.Type.BONUS: BulletEffect.COLLECT, Item.Type.DOOR: BulletEffect.BLOCK, Item.Type.HYPER: BulletEffect.COLLECT, Item.Type.ROCK: BulletEffect.BLOCK, Item.Type.BOMB: BulletEffect.BLOCK, Item.Type.WALL: BulletEffect.BLOCK, Item.Type.SOFTWALL: BulletEffect.BLOCK, Item.Type.EMPTY: BulletEffect.IGNORE, Item.Type.MYSTERY: BulletEffect.BLOCK, Item.Type.CLUSTER: BulletEffect.OTHER, Item.Type.APPLE_DIAMOND: BulletEffect.BLOCK}

enum BulletEffect {
    IGNORE,
    BLOCK,
    COLLECT,
    DESTROY,
    OTHER
}

var grvmap: GrvMap

var queue: TimerItem.Queue

## Holds a reference to the game scene's root node.
var gamescene: Node

## Holds the current color palette. See [constant palettes] for the list of color palettes.
var palette: Array = palettes[0]

## Holds the 7 color palettes used by the game.
const palettes = [
    ["blue", "brown"],
    ["red", "gray"],
    ["pink", "green"],
    ["green", "pink"],
    ["brown", "cyan"],
    ["cyan", "blue"],
    ["gray", "red"]
]

## The atlas for each color of dirt.
const dirt = {"blue": 14, "brown": 15, "red": 17, "gray": 18, "pink": 19, "green": 20, "cyan": 21}

## The atlas for each color of wall.
const walls = {"blue": 7, "brown": 8, "red": 9, "gray": 10, "pink": 11, "green": 12, "cyan": 13}

## The atlas for each color of soft wall.
const soft_walls = {"gray": 0, "blue": 1, "brown": 2, "red": 3, "pink": 4, "green": 5, "cyan": 6}

## Holds the colors used for the background of each color.
const colors = {"blue": Color("#0020aa"), "brown": Color("#a97142"), "red": Color("#aa0f00"), "gray": Color("#aaaaaa"), "pink": Color("#aa23aa"), "green": Color("#02aa00"), "cyan": Color("#00aaaa")}

## Holds the text color used for each color.
const text_colors = {"blue": Color.WHITE, "red": Color.WHITE, "brown": Color.WHITE, "gray": Color.WHITE, "pink": Color.WHITE, "green": Color.WHITE, "cyan": Color.WHITE}

## Defines the four movement "types" which denote what properties a tile has for movement purposes.
enum MOVE_TYPE {
    EMPTY,
    DIG,
    ROCK,
    BLOCKED
}

func _ready():
    gamescene = $"../game"
    chmenu = preload("res://cheatmenu.tscn").instantiate()
    add_sibling.call_deferred(chmenu)
    chmenu.hide()

func _process(_delta: float) -> void:
    if !chmenu.visible:
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func lose_level():
    lives -= 1
    level -= 1
    level_streak = -1
    load_next_level()

func get_tile_atlas(tile: Tile) -> int:
    match tile.type:
        Tile.TYPE.EMPTY:
            return -1
        Tile.TYPE.DIRT:
            return dirt[palette[tile.color]]
        Tile.TYPE.SOFT_WALL:
            return soft_walls[palette[tile.color]]
        Tile.TYPE.WALL:
            return walls[palette[tile.color]]
    push_warning("Tile's type is invalid. Returning -1.")
    return -1

func get_border_atlas() -> int:
    return walls[palette[0]]

## Takes two tile coordinates ([param to] and [param from]) and returns the [enum MOVE_TYPE] that corresponds to that tile [b]given the movement being attempted[b].[br][br]For example, if the player is moving into a rock that cannot be pushed, it will return MOVE_TYPE_BLOCKED, not MOVE_TYPE_ROCK.
func get_movement_type(to: Vector2i, from: Vector2i) -> MOVE_TYPE:
    var mtile = grvmap.at(to)
    if mtile.oob():
        return MOVE_TYPE.BLOCKED
    if mtile.node is FallingObj:
        var move_offset = to - from
        if move_offset.y != -1:
            var push = to + move_offset
            if grvmap.at(push).item.is_tunnel():
                return MOVE_TYPE.ROCK
            else:
                return MOVE_TYPE.BLOCKED
        else:
            return MOVE_TYPE.BLOCKED
    else:
        if mtile.item.is_tunnel():
            return MOVE_TYPE.EMPTY
        if mtile.node is BlockingObj or mtile.item.type == Item.Type.WALL:
            return MOVE_TYPE.BLOCKED
        return MOVE_TYPE.DIG


## Push the rock in [param rock] to [param to], if possible. Returns whether or not the push was successful.
func push_rock(rock: MapTile, to: Vector2i) -> bool:
    if get_movement_type(to, rock.xy):
        return false
    rock.node.start_pos = rock.xy
    rock.node.goal_pos = to
    remove_dirt(rock)
    return true

## Dig the tile at [param pos].
func dig(pos: Vector2i):
    var mtile = grvmap.at(pos)
    if !mtile.item.in_tunnel():
        if mtile.item.type == Item.Type.SOFTWALL:
            score -= (level + 1) * 5
        gamescene.get_node("ground_tiles").set_cells_terrain_connect([pos], 0, -1)
    if mtile.node:
        if mtile.node is Collectible:
            mtile.node.collect()

func remove_dirt(mtile: MapTile):
    gamescene.get_node("ground_tiles").set_cells_terrain_connect([mtile.xy], 0, -1)
    mtile.dig()

func bomb_tile(pos: Vector2i):
    var mtile = grvmap.at(pos)
    if mtile.oob():
        return
    remove_dirt(mtile)
    match bomb_actions[mtile.item.type]:
        BombAction.NONE:
            pass
        BombAction.COLLECT:
            mtile.node.collect()
        BombAction.DESTROY:
            mtile.changetype(Item.Type.EMPTY)
            if mtile.node:
                mtile.rmv_obj()
        BombAction.OTHER:
            mtile.node.bombed()

## Attempt to shoot a tile. Returns whether or not the bullet should continue.
func shoot_tile(pos: Vector2i, movement: Vector2i) -> bool:
    var mtile = grvmap.at(pos)
    if mtile.oob():
        return false
    match bullet_effects[mtile.item.type]:
        BulletEffect.IGNORE:
            return true
        BulletEffect.BLOCK:
            return false
        BulletEffect.COLLECT:
            mtile.node.collect()
            return false
        BulletEffect.DESTROY:
            mtile.rmv_obj()
            return false
        BulletEffect.OTHER:
            mtile.node.hit_by_bullet(movement)
            return false
    return false

func fire_bullet(from: Vector2i, movement: Vector2i):
    while true:
        from += movement
        if !shoot_tile(from, movement):
            print("bullet landed at ", from)
            break

func load_next_level():
    gamescene.queue_free()
    gamescene = preload("res://game.tscn").instantiate()
    level += 1
    level_streak += 1
    for shot in ammo:
        if randf() > 0.1:
            ammo -= 1 # 10% chance to keep unused shots. (Really a 90% chance to lose each shot)
    get_tree().get_root().add_child.call_deferred(gamescene)

func load_level():
    chmenu.hide()
    palette = palettes[level % 7]
    RenderingServer.set_default_clear_color(colors[palette[0]])
    preload("res://grvtheme.tres").set_color("font_color", "Label", text_colors[palette[0]])
    hyper = [false, false, false, false, false]
    score = score
    level = level
    ammo = ammo
    has_lost_level = false
    for letter in Item.visuals[Item.Type.HYPER]:
        gamescene.get_node("UI/hyper_" + letter).play(letter)
    game_clock.wait_time = (0.15*grvFileLoader.levelcount)/(GameManager.level+grvFileLoader.levelcount)
    game_clock.connect("timeout", _new_tick)
    queue = TimerItem.Queue.new()
    var map = Map.new(grvFileLoader.get_level_path(level))
    grvmap = map.grvmap
    LevelBuilder.build_level(map)
    bonus_dot_off()
    GameTime.start()
    game_clock.start()

func bonus_dot_on(_timeritem = null) -> bool:
    print("BONUS")
    bonus = true
    if grvmap.itemcount[Item.Type.BONUS]:
        queue.add(bonus_dot_off, GameTime.now() + 12)
        return true
    else:
        return false

func bonus_dot_off(_timeritem = null) -> bool:
    print("No bonus")
    bonus = false
    if grvmap.itemcount[Item.Type.BONUS]:
        queue.add(bonus_dot_on, GameTime.now() + 120)
        return true
    else:
        return false

func _new_tick():
    if has_lost_level:
        lose_level()
    queue.poll(GameTime.now())

func load_cheat_menu() -> Window:
    pause()
    chmenu.show()
    return chmenu

func pause():
    game_clock.paused = true
    GameTime.pause()

func resume():
    game_clock.paused = false
    GameTime.unpause()
