class_name Ghost extends Character

func _ready():
    super._ready()
    process_priority = map_tile.prio

func sort_closer_player(a, b):
    var player_pos = map_tile.map.player.xy
    return a.distance_squared_to(player_pos) < b.distance_squared_to(player_pos)

func original_ai() -> void:
    var possible_movements = [board_pos, board_pos, board_pos, board_pos]
    possible_movements[0].x += 1
    possible_movements[1].x -= 1
    possible_movements[2].y += 1
    possible_movements[3].y -= 1
    possible_movements.shuffle()
    possible_movements.sort_custom(sort_closer_player)
    var chosen_movement = board_pos
    for movement in possible_movements:
        if GameManager.get_movement_type(movement, board_pos) == GameManager.MOVE_TYPE.EMPTY:
            var goal_tile = map_tile.map.at(movement)
            if goal_tile.item.type == Item.Type.PLAYER or goal_tile.item.type == Item.Type.EMPTY:
                chosen_movement = movement
                break
        goal_pos = chosen_movement

# Compare two numbers; return -1 if a < b, +1 if a > b, or 50% chance of each if a == b
static func randcmp(a : int, b : int) -> int:
    if a < b:
        return -1;                  # Left/up
    elif a > b:
        return 1;                   # Down/right
    else:
        return 1 - (randi() & 2)    # Either 1 or -1

func alternate_ai() -> void:
    var map   : GrvMap = map_tile.map
    var delta : Vector2i = map.player.xy - map_tile.xy
    var xmov  : Vector2i = Vector2i(randcmp(delta.x, 0), 0)
    var ymov  : Vector2i = Vector2i(0, randcmp(delta.y, 0))
    var moves : Array[Vector2i]

    if (randcmp(abs(delta.x), abs(delta.y)) > 0):
        # x movement preferred
        moves = [xmov, ymov, -ymov, -xmov]
    else:
        # y movement preferred
        moves = [ymov, xmov, -xmov, -ymov]

    for m in moves:
        var to : MapTile = map_tile.dv(m)
        if to.item.is_tunnel() or to.item.type == Item.Type.PLAYER:
            if to.item.type != Item.Type.PLAYER or !GameManager.has_won_level:
                goal_pos = Vector2(to.xy)
                break
    # Otherwise stay put...

func _new_tick():
    board_pos = goal_pos.round()
    start_pos = board_pos
    alternate_ai()
    super._new_tick()

func _collided(area):
    if area.get_parent() is Player:
        GameManager.has_lost_level = true
