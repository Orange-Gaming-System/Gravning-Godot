@icon("res://Node Icons/node/icon_hammer.png")
class_name Level_Builder extends Node

var obj_classes = {Item.Type.PLAYER: Player, Item.Type.CHERRY: Cherry, Item.Type.AMMO: Ammo, Item.Type.APPLE: Apple, Item.Type.DIAMOND: Diamond, Item.Type.GHOST: Ghost, Item.Type.FROZEN_CHERRY: FrozenCherry, Item.Type.THAWED_CHERRY: ThawedCherry, Item.Type.BONUS: BonusCoin, Item.Type.DOOR: Door, Item.Type.HYPER: Hyper, Item.Type.ROCK: Rock, Item.Type.BOMB: Bomb, Item.Type.MYSTERY: Mystery, Item.Type.CLUSTER: ClusterBomb}

## Builds background tiles from a tilemap

## Gameboard size including border [b]minus the outermost frame of tiles[/b]
const gameboard_rect = Rect2i(-18+1, -4+1, 76-2, 30-2)

func generate_ground(map : Map, rect : Rect2i = gameboard_rect):
    var ground_tiles : TileMapLayer = GameManager.gamescene.get_node("ground_tiles")
    var border_atlas = GameManager.get_border_atlas()
    var grvmap : GrvMap = map.grvmap
    var tiles = map.tiles
    rect = rect.grow(1)

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

# Temporary Constants for test level.
@warning_ignore("int_as_enum_without_cast")
var ent = Tile.new(0, 0)
@warning_ignore("int_as_enum_without_cast")
var swp = Tile.new(3, 0)
@warning_ignore("int_as_enum_without_cast")
var sws = Tile.new(3, 1)
@warning_ignore("int_as_enum_without_cast")
var wwp = Tile.new(2, 0)
@warning_ignore("int_as_enum_without_cast")
var wws = Tile.new(2, 1)

## Builds the level from [param map], which is a [Map].
func build_level(map: Map):
    generate_ground(map)
    generate_objs(map.objs)
