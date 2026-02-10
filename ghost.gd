class_name Ghost extends Character

func _new_tick():
    board_pos = goal_pos
    start_pos = board_pos
    var possible_movements = [board_pos, board_pos, board_pos, board_pos]
    possible_movements[0].x += 1
    possible_movements[1].x -= 1
    possible_movements[2].y += 1
    possible_movements[3].y -= 1
    var allowed_movements = []
    for movement in possible_movements:
        if GameManager.get_movement_type(movement, board_pos) == GameManager.MOVE_TYPE.EMPTY:
            var goal_obj = map_tile.map.at(movement)
            if goal_obj.item.type == Item.Type.PLAYER or goal_obj.item.type == Item.Type.EMPTY:
                allowed_movements.append(movement)
    var movement_distances = []
    var player_pos = map_tile.map.player.xy
    for movement in allowed_movements:
        movement_distances.append(movement.distance_squared_to(player_pos))
    var smallests = []
    for i in movement_distances.size():
        if movement_distances[i] == movement_distances.min():
            smallests.append(i)
    goal_pos = allowed_movements[smallests.pick_random()]
    super._new_tick()
        
    

func _collided(area):
    if area.get_parent() is Player:
        print("You lose!")
