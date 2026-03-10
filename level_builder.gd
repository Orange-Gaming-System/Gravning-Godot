@icon("res://Node Icons/node/icon_hammer.png")
class_name Level_Builder extends Node

var obj_classes = {Item.Type.PLAYER: Player, Item.Type.CHERRY: Cherry, Item.Type.AMMO: Ammo, Item.Type.APPLE: Apple, Item.Type.DIAMOND: Diamond, Item.Type.GHOST: Ghost, Item.Type.FROZEN_CHERRY: FrozenCherry, Item.Type.THAWED_CHERRY: ThawedCherry, Item.Type.BONUS: BonusCoin, Item.Type.DOOR: Door, Item.Type.HYPER: Hyper, Item.Type.ROCK: Rock, Item.Type.BOMB: Bomb, Item.Type.MYSTERY: Mystery, Item.Type.CLUSTER: ClusterBomb}

## Builds background tiles from a tilemap
func generate_ground(map : Map, rect : Rect2i, zap : bool = false):
    var ground_tiles : TileMapLayer = GameManager.gamescene.get_node("ground_tiles")
    var border_atlas : int = GameManager.get_border_atlas()
    var grvmap : GrvMap = map.grvmap
    var tiles = map.tiles
    rect = rect.grow(1)

    if zap:
        ground_tiles.clear()

    for y in range(rect.position.y, rect.end.y):
        for x in range(rect.position.x, rect.end.x):
            var xy : Vector2i = Vector2i(x, y)
            var mtile : MapTile = grvmap.at(xy)
            var atlas = border_atlas
            var tilecoord = Vector2i(-1, -1)
            if !mtile.item.in_tunnel():
                tilecoord = mtile.tileatlascoord()
                if !mtile.oob():
                    atlas = GameManager.get_tile_atlas(tiles[y][x])
            ground_tiles.set_cell(xy, atlas, tilecoord)

## Generates all object nodes from an array of [MapTile].
func generate_objs(objs: Array):
    for obj in objs:
        obj.spawn_obj()

## Builds the level from [param map], which is a [Map].
func build_level(map: Map):
    var gameboard_rect : Rect2i = Rect2i(0, 0, map.grvmap.size.x, map.grvmap.size.y)
    generate_ground(map, gameboard_rect, true)
    generate_objs(map.objs)
