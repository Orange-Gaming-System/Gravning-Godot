class_name Rock extends FallingObj


func _ready():
    super._ready()
    play(str(map_tile.item.visual))

func is_valid_fall(to: Vector2i, from: Vector2i):
    var move_type = GameManager.get_movement_type(to, from)
    if move_type == GameManager.MOVE_TYPE.EMPTY:
        return true
    elif move_type == GameManager.MOVE_TYPE.DIG:
        var item = map_tile.map.at(to).item
        if item.type == Item.Type.DIAMOND or !item.in_tunnel():
            return false
        return true
    return false
            
        
    
