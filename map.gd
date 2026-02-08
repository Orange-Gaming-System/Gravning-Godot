class_name Map extends RefCounted


## A 2D array of [Tile] which stores all tiles. Each array it contains is 1 row. Accessed as tiles[y][x].
@export var tiles: Array

## An array of [MapTile] which stores all objects (anything that isn't a Wall, Soft Wall, or Empty).
@export var objs: Array

var grvmap: GrvMap

func _init(path: String):
    grvmap =  GrvMap.new(FileAccess.get_file_as_bytes(path), GameManager.level)
    grvmap.generate(false)
    var empty_row = Array()
    empty_row.resize(grvmap.size.x)
    tiles = Array()
    for row in grvmap.size.y:
        tiles.append(empty_row.duplicate())
    for t in grvmap.tile:
        if t.item.type == Item.Type.WALL:
            tiles[t.xy.y][t.xy.x] = Tile.new(Tile.TYPE.WALL, t.item.flags & Item.Flags.BG2 as Tile.COLOR)
        elif t.item.type == Item.Type.SOFTWALL:
            tiles[t.xy.y][t.xy.x] = Tile.new(Tile.TYPE.SOFT_WALL, t.item.flags & Item.Flags.BG2 as Tile.COLOR)
        else:
            if t.item.flags & Item.Flags.TUNNEL:
                tiles[t.xy.y][t.xy.x] = Tile.new(Tile.TYPE.EMPTY, t.item.flags & Item.Flags.BG2 as Tile.COLOR)
            else:
                tiles[t.xy.y][t.xy.x] = Tile.new(Tile.TYPE.DIRT, t.item.flags & Item.Flags.BG2 as Tile.COLOR)
            if LevelBuilder.obj_classes.has(t.item.type):
                objs.append(t)
