class_name ClusterBomb extends FallingObj

const bullet_directions = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

func hit_by_bullet(movement):
    for direction in bullet_directions:
        if -direction != movement:
            GameManager.fire_bullet(board_pos, direction)
    map_tile.rmv_obj()
