class_name ThawedCherry extends Cherry

func collect():
    var next_thaw = map_tile.map.thaw()
    if next_thaw:
        next_thaw.rmv_obj()
        next_thaw.changetype(Item.Type.THAWED_CHERRY)
        next_thaw.spawn_obj()
    super.collect()
