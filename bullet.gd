class_name Bullet extends Projectile

var is_cluster: bool

func _init(_map: GrvMap, pos: Vector2i, _movement: Vector2i, _speed: float, _is_cluster: bool):
    super._init(_map, pos, _movement, _speed)
    is_cluster = _is_cluster

const bullets = {Vector2i.UP: "bU", Vector2i.DOWN: "bD", Vector2i.LEFT: "bL", Vector2i.RIGHT: "bR"}
const cluster_bullets = {Vector2i.UP: "cU", Vector2i.DOWN: "cD", Vector2i.LEFT: "cL", Vector2i.RIGHT: "cR", Vector2i(1, 1): "cDR", Vector2i(1, -1): "cUR", Vector2i(-1, 1): "cUR", Vector2i(-1, -1): "cUL"}

func _ready():
    sprite_frames = GameManager.other_frames.bullet
    if is_cluster:
        play(cluster_bullets[movement])
    else:
        play(bullets[movement])
