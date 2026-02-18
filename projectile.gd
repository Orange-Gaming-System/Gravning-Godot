class_name Projectile extends AnimatedSprite2D

var map: GrvMap
var map_pos: Vector2i
var board_pos: Vector2
var movement: Vector2i
var speed: float

var next_tile: Vector2i

# map is the GrvMap of the current level. pos is the integer position of the object firing the projectile. movement is the movement vector in board tiles. speed is the amount of time, in seconds, it takes the projectile to travel by movement.
func _init(_map: GrvMap, pos: Vector2i, _movement: Vector2i, _speed: float):
    map = _map
    map_pos = pos
    board_pos = pos
    movement = _movement
    speed = _speed
    next_tile = pos + movement
    GameManager.projectiles += 1

## Checks if [param new] is farther from [param original] than [param comp]. If it is, returns true.
func is_further(original: Vector2, new: Vector2, comp: Vector2) -> bool:
    var new_dist = original.distance_squared_to(new)
    var comp_dist = original.distance_squared_to(comp)
    return new_dist > comp_dist

func _process(delta: float) -> void:
    board_pos = board_pos + movement * (delta / speed)
    var cont = true
    while is_further(map_pos, board_pos, next_tile):
        cont = GameManager.shoot_tile(next_tile, movement)
        if cont:
            map_pos = next_tile
            next_tile = map_pos + movement
        else:
            break
    if !cont:
        GameManager.projectiles -= 1
        queue_free()
    position = board_pos * 16
