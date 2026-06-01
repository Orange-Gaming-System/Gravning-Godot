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

var has_won_level: bool = false

# Level loaded and ready to accept input
var level_loaded : bool = false

# If the level is paused. Note that this is not the same as the game being paused by projectiles!
var paused: bool = false:
    set(value):
        paused = value
        if projectiles <= 0:
            if value:
                pause()
            else:
                resume()

var endscreen : Control = null
const WAIT_TIME_END_OF_LEVEL    : float =  2.5
const BONUS_SPIN_TIME           : float =  1.5
const WAIT_TIME_GAME_OVER       : float =  15.0
const SUPER_BONUS_SPIN_TIME     : float =  5.0
const WAIT_TIME_WRAPAROUND      : float =  10.0

var grv_file: grvFile

var grvmap: GrvMap
var map: Map
var queue: TimerItem.Queue
var audio: GrvAudio = GrvAudio.new()

var grvtheme: GrvTheme

var lives: int = 3:
    set(value):
        lives = value
        if lives > 6:
            lives = 6
        gamescene.get_node("UI/lives").region_rect.size.x = max(lives * 32, 0)

## Holds the current score. Can be negative!
var score: int = 0:
    set(value):
        score = value
        gamescene.get_node("UI/score").text = str(score)

## The total amount of the player's score that has come from Super Bonuses.
var super_bonus_total: int = 0

## The amount of ammo the player has.
var ammo: int = 0:
    set(value):
        ammo = value
        if value > 99:
            ammo = 99
        gamescene.get_node("UI/ammo").visible = ammo
        gamescene.get_node("UI/Fixed/ammo").visible = ammo
        gamescene.get_node("UI/ammo").text = str(ammo)

## The amount of power the player has.
var power: int = 0:
    set(value):
        power = value
        if value > 9999:
            power = 9999
        gamescene.get_node("UI/power").text = str(power)

## Holds whether or not bonus dots will give score right now.
var bonus: bool = false

var hyper: Array[bool] = [false, false, false, false, false]

var is_easter_egg_level: bool = false

var is_base_game: bool = false

var has_seen_easter_egg: bool = false

## Holds the current number of projectiles active on screen. If greater than 0, time is paused.
var projectiles: int = 0:
    set(value):
        projectiles = value
        if projectiles > 0:
            pause()
        else:
            resume()

var jumpto: int = -1:
    set(value):
        jumpto = value
        if value == -1:
            gamescene.get_node("UI/jumpto").visible = false
            gamescene.get_node("UI/Fixed/jumpto").visible = false
        else:
            gamescene.get_node("UI/jumpto").visible = true
            gamescene.get_node("UI/Fixed/jumpto").visible = true
            gamescene.get_node("UI/jumpto").text = str(jumpto + 1)

var game_clock: Timer

var global_sound: AudioStreamPlayer

## Holds a reference to the current active cheat menu (or null if nonexistent).
var chmenu: Window

const bomb_actions: Dictionary[Item.Type, BombAction] = {Item.Type.CHERRY: BombAction.COLLECT, Item.Type.AMMO: BombAction.DESTROY, Item.Type.PLAYER: BombAction.OTHER, Item.Type.APPLE: BombAction.NONE, Item.Type.DIAMOND: BombAction.DESTROY, Item.Type.GHOST: BombAction.OTHER, Item.Type.FROZEN_CHERRY: BombAction.NONE, Item.Type.THAWED_CHERRY: BombAction.COLLECT, Item.Type.BONUS: BombAction.OTHER, Item.Type.DOOR: BombAction.NONE, Item.Type.HYPER: BombAction.NONE, Item.Type.ROCK: BombAction.NONE, Item.Type.BOMB: BombAction.NONE, Item.Type.WALL: BombAction.DESTROY, Item.Type.SOFTWALL: BombAction.DESTROY, Item.Type.EMPTY: BombAction.NONE, Item.Type.MYSTERY: BombAction.DESTROY, Item.Type.CLUSTER: BombAction.NONE, Item.Type.APPLE_DIAMOND: BombAction.NONE, Item.Type.FUTURE_GHOST: BombAction.NONE, Item.Type.PAST_GHOST: BombAction.OTHER, Item.Type.PAST_FUTURE_GHOST: BombAction.OTHER}

enum BombAction {
    NONE,
    COLLECT,
    DESTROY,
    OTHER
}

const bullet_effects: Dictionary[Item.Type, BulletEffect] = {Item.Type.CHERRY: BulletEffect.COLLECT, Item.Type.AMMO: BulletEffect.COLLECT, Item.Type.PLAYER: BulletEffect.OTHER, Item.Type.APPLE: BulletEffect.BLOCK, Item.Type.DIAMOND: BulletEffect.COLLECT, Item.Type.GHOST: BulletEffect.OTHER, Item.Type.FROZEN_CHERRY: BulletEffect.BLOCK, Item.Type.THAWED_CHERRY: BulletEffect.COLLECT, Item.Type.BONUS: BulletEffect.COLLECT, Item.Type.DOOR: BulletEffect.BLOCK, Item.Type.HYPER: BulletEffect.COLLECT, Item.Type.ROCK: BulletEffect.BLOCK, Item.Type.BOMB: BulletEffect.BLOCK, Item.Type.WALL: BulletEffect.BLOCK, Item.Type.SOFTWALL: BulletEffect.BLOCK, Item.Type.EMPTY: BulletEffect.IGNORE, Item.Type.MYSTERY: BulletEffect.BLOCK, Item.Type.CLUSTER: BulletEffect.OTHER, Item.Type.APPLE_DIAMOND: BulletEffect.BLOCK, Item.Type.FUTURE_GHOST: BulletEffect.IGNORE, Item.Type.PAST_GHOST: BulletEffect.OTHER, Item.Type.PAST_FUTURE_GHOST: BulletEffect.OTHER}

enum BulletEffect {
    IGNORE,
    BLOCK,
    COLLECT,
    DESTROY,
    OTHER
}

const ghost_speed_mods: Dictionary[GhostMod, float] = {GhostMod.NONE: 1, GhostMod.FREEZE: 0, GhostMod.THAW: 0, GhostMod.SCARED: -1, GhostMod.SLOW: 1}

var ghost_modifier: GhostMod = GhostMod.NONE

enum GhostMod {
    NONE,
    FREEZE,
    THAW,
    SCARED,
    SLOW
}

## Holds a reference to the game scene's root node.
var gamescene: Node = null

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
## These should match the color used for the interior of a wall for the
## specified color.
const colors = {"blue": Color("#111635"), "brown": Color("#361e11"), "red": Color("#351117"), "gray": Color("#1c212a"), "pink": Color("#351125"), "green": Color("#10300f"), "cyan": Color("#113535")}

## Holds the text color used for each color.
const text_colors = {"blue": Color.WHITE, "red": Color.WHITE, "brown": Color.WHITE, "gray": Color.WHITE, "pink": Color.WHITE, "green": Color.WHITE, "cyan": Color.WHITE}

## Defines the four movement "types" which denote what properties a tile has for movement purposes.
enum MOVE_TYPE {
    EMPTY,
    DIG,
    ROCK,
    BLOCKED
}

var fade_message = false
var message_timer: TimerItem
var bonus_spin_target : int = 0
var bonus_spin_step   : int = 0
var bonus_spin_ctr    : int = 0
var bonus_spin_base   : int = 0
var bonus_spin_label  : Label

func _ready():
    chmenu = preload("res://cheatmenu.tscn").instantiate()
    add_sibling.call_deferred(chmenu)
    chmenu.hide()
    grvtheme = preload("res://themes/default/grvtheme.tres").load_theme()

func _process(delta: float) -> void:
    if !chmenu.visible and gamescene:
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if bonus_spin_step:
        var spin_bonus : int = bonus_spin_ctr + roundi(bonus_spin_step * delta)
        if spin_bonus >= bonus_spin_target:
            spin_bonus = bonus_spin_target
            bonus_spin_step = 0
            global_sound.stop()
        elif global_sound.stream != audio.sound_data.score_counter or !global_sound.playing:
            global_sound.play_sound(audio.sound_data.score_counter)
        score += spin_bonus - bonus_spin_ctr
        bonus_spin_ctr = spin_bonus
        if bonus_spin_label:
            bonus_spin_label.text = str(bonus_spin_ctr)

    if fade_message:
        var msgnode = gamescene.get_node("UI/message")
        if msgnode.self_modulate.a < delta:
            msgnode.self_modulate.a = 0.0
            fade_message = false
        else:
            msgnode.self_modulate.a -= delta

func game_over() -> void:
    endscreen = gamescene.get_node("ending/gameover")
    endscreen.visible = true
    gamescene.end_timer.wait_time = WAIT_TIME_GAME_OVER
    global_sound.play_sound(audio.sound_data.game_over)
    gamescene.end_timer.start()

# Called from titlescreen/buttons/play
func prepare_game(game_file: grvFile = null) -> void:
    level_loaded = false
    if game_file:
        grv_file = game_file
    gamescene = preload("res://game.tscn").instantiate()
    get_tree().get_root().add_child.call_deferred(gamescene)

var is_wraparound = false

# Called from gamescene._ready()
func start_game() -> void:
    pause()
    game_clock.connect("timeout", _new_tick)
    gamescene.end_timer.timeout.connect(endscreen_timeout)
    if !is_wraparound:
        level           =  0
        level_streak    =  0
        ammo            =  0
        score           =  0
        lives           =  3
        power           =  0
        has_seen_easter_egg = false
    is_wraparound = false
    load_level()

func end_game() -> void:
    kill_endscreen()            # Just in case
    gamescene.queue_free()
    get_tree().get_root().add_child(preload("res://titlescreen.tscn").instantiate())

func win_level(gtime : float) -> void:
    # Setup end screen.

    pause(gtime)

    var cherries_left  : int = grvmap.cherries()
    var cherries_taken : float = float(grvmap.startcherries - cherries_left)/grvmap.startcherries
    if cherries_left:
        endscreen = gamescene.get_node("ending/treasure")
        endscreen.get_node("cherries/cherries").text = str(floori(cherries_taken * 100.0)) + "%"
    else:
        endscreen = gamescene.get_node("ending/cleared")

    endscreen.get_node("time/time").text = GameTime.format(gtime)

    # Determine and display performance bonus.
    bonus_spin_target = roundi((30000 * (level + 1)) * cherries_taken/gtime)
    bonus_spin_label = endscreen.get_node("pbonus/pbonus")
    bonus_spin_label.text = "0"
    bonus_spin_ctr    = 0
    bonus_spin_step   = roundi(bonus_spin_target / BONUS_SPIN_TIME)

    endscreen.visible = true

    gamescene.end_timer.wait_time = WAIT_TIME_END_OF_LEVEL
    gamescene.end_timer.start()
    has_lost_level = false

func lose_level() -> void:
    pause()
    lives -= 1
    level_streak = 0
    jumpto = -1
    if lives < 0:
        game_over()
    else:
        for shot in ammo:
            if randf() > 0.1:
                ammo -= 1 # 10% chance to keep unused shots. (Really a 90% chance to lose each shot)
        load_level()

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

func set_background_color() -> void:
    return RenderingServer.set_default_clear_color(colors[palette[0]])

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
    rock.node.was_just_pushed = true
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
    mtile.dig()
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

func super_bonus():
    level = jumpto
    jumpto = -1
    gamescene.queue_free()
    gamescene = preload("res://super_bonus.tscn").instantiate()
    add_sibling(gamescene)

    global_sound = gamescene.get_node("global_sound")

    gamescene.get_node("score").text = str(score)

    # Calculate Super Bonus

    @warning_ignore("integer_division")
    bonus_spin_target = 3 * (score - super_bonus_total) / 2
    super_bonus_total += bonus_spin_target
    bonus_spin_label = gamescene.get_node("superbonus")
    bonus_spin_label.text = "0"
    bonus_spin_ctr    = 0
    bonus_spin_step   = roundi(bonus_spin_target / SUPER_BONUS_SPIN_TIME)

    gamescene.get_node("next_level").text = "Now you get to try again, starting\nfrom level " + str(level + 1) + "."

    # Handle ending.

    is_wraparound = true

    gamescene.get_node("wait").timeout.connect(wraparound)
    gamescene.get_node("wait").start(WAIT_TIME_WRAPAROUND)

func wraparound():
    GameManager.grv_file = grvFile.new("res://levels/grv/grv.grv")
    var hs_anim = preload("res://hyperspace_animation.tscn").instantiate()
    hs_anim.levels = Array(range(grv_file.levelcount - 1, level, -1), Variant.Type.TYPE_INT, &"", null)
    if hs_anim.levels == []:
        hs_anim.levels.append(grv_file.levelcount - 1)
    print(hs_anim.levels)
    hs_anim.object_speed = -10
    hs_anim.object_spawn = 0
    hs_anim.object_destroy = -25
    hs_anim.time = 12.7 / (5 / hs_anim.levels.size())

    add_sibling(hs_anim)
    gamescene.queue_free()

func load_level():
    level_loaded = false
    kill_endscreen()            # Just in case
    chmenu.hide()
    palette = palettes[level % palettes.size()]
    if is_easter_egg_level:
        palette = ["gray", "brown"]
    set_background_color()
    grvtheme.theme.set_color("font_color", "Label", text_colors[palette[0]])
    if is_easter_egg_level:
        if hyper.has(true):
            gamescene.get_node("UI/hyper_H").visible = true
            gamescene.get_node("UI/hyper_Y").visible = true
            gamescene.get_node("UI/hyper_P").visible = true
            gamescene.get_node("UI/hyper_E").visible = true
            gamescene.get_node("UI/hyper_R").visible = true
        has_seen_easter_egg = true
    else:
        hyper = [false, false, false, false, false]
    bonus_spin_step = 0
    score = score + (bonus_spin_target - bonus_spin_ctr)
    bonus_spin_target = 0
    bonus_spin_ctr = 0
    level = level
    ammo = ammo
    power = power
    lives = lives
    gamescene.get_node("UI/scrt_crdts").visible = is_easter_egg_level
    gamescene.get_node("UI/lvlctr_egg").visible = is_easter_egg_level
    message_timer = null
    fade_message = false
    gamescene.get_node("UI/message").text = ""
    ghost_modifier = GhostMod.NONE
    queue = TimerItem.Queue.new()
    if level >= grv_file.levelcount - 1:
        jumpto = grv_file.levelcount
        reduce_jumpto(null)
        ammo = 0
    else:
        jumpto = -1
    projectiles = 0
    has_lost_level = false
    has_won_level = false
    for old_obj in gamescene.objects.get_children():
        old_obj.delete()

    if !is_easter_egg_level:
        for letter in Item.visuals[Item.Type.HYPER]:
            var node : AnimatedSprite2D = gamescene.get_node("UI/hyper_" + letter)
            node.visible = false
            node.play(letter)

    game_clock.wait_time = (0.15*grv_file.levelcount)/(GameManager.level+grv_file.levelcount)
    var lvl_path = grv_file.get_level_path(level)

    if is_easter_egg_level:
        gamescene.get_node("UI/level").text = ""
        lvl_path = "res://levels/test/secret.grvmap"

    var startup_sound = "startup"

    if is_easter_egg_level:
        startup_sound = "startup_reward"
    elif GameManager.level >= grv_file.levelcount - 1:
        startup_sound = "startup_boss"

    map = Map.new(lvl_path)
    grvmap = map.grvmap
    LevelBuilder.build_level(map)

    is_easter_egg_level = false

    bonus_dot_off()
    level_loaded = true
    GameTime.start()
    game_clock.start()

    global_sound.play_sound(audio.sound_data[startup_sound])

func bonus_dot_on(_timeritem = null) -> bool:
    if !grvmap.itemcount[Item.Type.BONUS]:
        return false
    bonus = true
    gamescene.get_node("UI/bonus_anim").play()
    queue.add(bonus_dot_off, GameTime.now() + 12)
    return true

func bonus_dot_off(_timeritem = null) -> bool:
    bonus = false
    if grvmap.itemcount[Item.Type.BONUS]:
        queue.add(bonus_dot_on, GameTime.now() + 120)
        return true
    else:
        return false

func endscreen_timeout() -> void:
    if kill_endscreen():
        if lives < 0:
            end_game()
        else:
            level += 1
            level_streak += 1
            if jumpto > -1:
                super_bonus()
                return
            for shot in ammo:
                if randf() > 0.1:
                    ammo -= 1 # 10% chance to keep unused shots. (Really a 90% chance to lose each shot)
            if hyper.has(true):
                GameManager.grv_file = grvFile.new("res://levels/grv/grv.grv")
                var hs_anim = preload("res://hyperspace_animation.tscn").instantiate()
                hs_anim.levels = Array(range(level, level + hyper.count(true)), Variant.Type.TYPE_INT, &"", null)
                print(hs_anim.levels)
                hs_anim.object_speed = 10
                hs_anim.object_spawn = -25
                hs_anim.object_destroy = 0
                hs_anim.time = 12.7 / (5 / hs_anim.levels.size())

                level += hyper.count(true)
                add_sibling(hs_anim)
                gamescene.queue_free()
                return
            load_level()

func kill_endscreen() -> bool:
    if endscreen:
        endscreen.visible = false
        endscreen = null
        return true
    else:
        return false

func _new_tick():
    var gtime : float = GameTime.now()

    for past_ghost in grvmap.items[Item.Type.PAST_GHOST].values():
        if !past_ghost.node:
            past_ghost.changetype(Item.Type.EMPTY)
    for future_ghost in grvmap.items[Item.Type.FUTURE_GHOST].values():
        if !future_ghost.node:
            future_ghost.changetype(Item.Type.EMPTY)

    if has_won_level:
        win_level(gtime)
    elif has_lost_level:
        lose_level()
    else:
        queue.poll(gtime)



func _input(_event):
    if not level_loaded:
        return
    if Input.is_action_just_pressed("skip_end_screen") and endscreen:
        gamescene.end_timer.stop()
        endscreen_timeout()
    if Input.is_action_just_pressed("skip_end_screen") and is_wraparound and gamescene:
        gamescene.get_node("wait").stop()
        wraparound()

func load_cheat_menu() -> Window:
    pause()
    chmenu.show()
    return chmenu

func pause(at_time : float = NAN) -> void:
    game_clock.paused = true
    GameTime.pause(at_time)

func resume() -> void:
    GameTime.unpause()
    game_clock.paused = false

func print_message(message: String, fade_time: float = 5):
    fade_message = false
    if message_timer:
        message_timer.disable()
    gamescene.get_node("UI/message").text = message
    gamescene.get_node("UI/message").self_modulate.a = 1.0
    message_timer = queue.add(begin_message_fade, GameTime.now() + fade_time)

func begin_message_fade(_timeritem):
    fade_message = true
    return false

func reduce_jumpto(_timeritem):
    jumpto -= 1
    if jumpto > 0:
        queue.add(reduce_jumpto, GameTime.now() + 10)
    return true

func thaw_ghosts(_timeritem):
    if ghost_modifier == GhostMod.FREEZE:
        ghost_modifier = GhostMod.THAW
        for ghost in grvmap.items[Item.Type.GHOST]:
            grvmap.items[Item.Type.GHOST][ghost].node.thaw()
    return true

func unfreeze_ghosts(_timeritem):
    if ghost_modifier == GhostMod.THAW:
        ghost_modifier = GhostMod.NONE
    return true

func unscare_ghosts(_timeritem):
    if ghost_modifier == GhostMod.SCARED:
        ghost_modifier = GhostMod.NONE
    return true

func unslow_ghosts(_timeritem):
    if ghost_modifier == GhostMod.SLOW:
        ghost_modifier = GhostMod.NONE
    return true
