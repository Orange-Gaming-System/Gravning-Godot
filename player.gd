@icon("res://Node Icons/node_2D/icon_character.png")
class_name Player extends Character

## Holds the most recent input.
var last_input: String = "_null"
## Holds whether or not the input held in [member last_input] was sent during the current tick.
var input_from_tick: bool = false



## The list of actions accepted by the player node.
const accepted_actions: Array[StringName] = ["left", "right", "up", "down", "escape"]

## The list of cheat actions and the corresponding action to execute.
var cheats: Dictionary[StringName, Callable] = {"instant_win": GameManager.load_next_level, "getammo": func(): GameManager.ammo += 1}

var bullet_dir: Dictionary[StringName, Vector2i] = {"shoot_left": Vector2i(-1, 0), "shoot_right": Vector2i(1, 0), "shoot_up": Vector2i(0, -1), "shoot_down": Vector2i(0, 1)}

# Input handler
func _input(event):
    for action in accepted_actions:
        if event.is_action(action):
            if Input.is_action_just_pressed(action):
                last_input = action
                input_from_tick = true
    for cheat in cheats:
        if event.is_action(cheat):
            if Input.is_action_just_pressed(cheat):
                cheats[cheat].call()
    if GameManager.ammo > 0:
        for dir in bullet_dir:
            if event.is_action(dir):
                if Input.is_action_just_pressed(dir):
                    GameManager.ammo -= 1
                    GameManager.fire_bullet(map_tile.xy, bullet_dir[dir])

func _new_tick() -> void:
    board_pos = goal_pos
    var new_pos = board_pos
    if input_from_tick or Input.is_action_pressed(last_input):
        if last_input != "escape":
            # code for standard movement.

            # move new_pos in the input direction.
            match str(last_input):
                "left":
                    new_pos.x -= 1
                "right":
                    new_pos.x += 1
                "up":
                    new_pos.y -= 1
                "down":
                    new_pos.y += 1
            # get movement type at position.
            var move_type = GameManager.get_movement_type(new_pos, board_pos)
            # print(move_type)
            # if our movement is blocked, don't move. If we move into a diggable tile, dig.
            match move_type:
                GameManager.MOVE_TYPE.DIG:
                    GameManager.dig(new_pos)
                GameManager.MOVE_TYPE.BLOCKED:
                    new_pos = board_pos
                GameManager.MOVE_TYPE.ROCK:
                    GameManager.push_rock(map_tile.map.at(new_pos), new_pos + (new_pos-board_pos))
                    new_pos = board_pos
        else:
            if GameManager.level >= grvFileLoader.escape_lvl:
                map_tile = map_tile.map.goodtile(MapTile.empty_tile)
                board_pos = map_tile.xy
                new_pos = board_pos
                GameManager.dig(board_pos)
    start_pos = board_pos
    goal_pos = new_pos
    map_tile = map_tile.map.move_player(goal_pos)
    input_from_tick = false

func hit_by_rock():
    GameManager.has_lost_level = true
    map_tile.rmv_obj()

func bombed():
    GameManager.has_lost_level = true
    map_tile.rmv_obj()

func hit_by_bullet(_movement):
    GameManager.has_lost_level = true
    map_tile.rmv_obj()

const smash_offset = 6
const smash_pattern: Array[int] = [0, 2, 3, 4, 4, 5, 5, 5, 4, 4, 3, 2, 0]
const big_smash_offset = 9
const big_smash_pattern: Array[int] = [0, 2, 4, 5, 6, 6, 7, 7, 7, 7, 7, 7, 7, 6, 6, 5, 4, 2, 0]

func smash(_timeritem):
    var pattern = smash_pattern
    var pattern_offset = smash_offset
    if randf() < 0.1:
        pattern = big_smash_pattern
        pattern_offset = big_smash_offset
    var bomb = Bomb.new(map_tile)
    bomb.bomb_pattern = pattern
    bomb.pattern_offset = pattern_offset
    bomb.event(_timeritem, true)
