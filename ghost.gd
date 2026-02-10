class_name Ghost extends Character

func _ready():
    super._ready()
    process_priority = map_tile.prio

func sort_closer_player(a, b):
    var player_pos = map_tile.map.player.xy
    return a.distance_squared_to(player_pos) < b.distance_squared_to(player_pos)

func _new_tick():
    board_pos = goal_pos
    start_pos = board_pos
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
    super._new_tick()

func _collided(area):
    if area.get_parent() is Player:
        print("You lose!")
