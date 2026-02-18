class_name ClusterBomb extends FallingObj

const bullet_directions = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

func hit_by_bullet(movement):
    for direction in bullet_directions:
        if -direction != movement:
            get_parent().add_child(Bullet.new(map_tile.map, goal_pos, direction, 0.01, true))
    map_tile.rmv_obj()
