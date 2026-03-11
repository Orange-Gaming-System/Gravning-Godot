class_name FallingObj extends MovingObj

## Holds a Callable to call to see if it is valid to fall to a given tile. Uses the same arguement structure as [method Game_Manager.get_movement_type]. Should return true if the movement is valid.
var validity_check: Callable = is_valid_fall

var was_just_pushed: bool = false

func _new_tick():
    if was_just_pushed:
        was_just_pushed = false
    else:
        board_pos = goal_pos.round()
    var current_pos = board_pos
    var fall_pos = board_pos + Vector2.DOWN
    if map_tile.map.at(fall_pos).item.is_tunnel() and map_tile.item.in_tunnel():
        while fall(current_pos, fall_pos):
            current_pos += Vector2.DOWN
            fall_pos += Vector2.DOWN
        board_pos = current_pos
        goal_pos = board_pos
    start_pos = board_pos
    super._new_tick()

func fall(from: Vector2i, to: Vector2i) -> bool:
    if validity_check.call(to, from):
        var mtile = map_tile.map.at(to)
        if mtile.node:
            mtile.node.hit_by_rock()
        return true
    else:
        return false

func is_valid_fall(to: Vector2i, _from: Vector2i):
    return map_tile.map.at(to).item.is_tunnel()
