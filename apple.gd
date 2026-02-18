@icon("res://Node Icons/node_2D/icon_tree.png")
class_name Apple extends BlockingObj

const diamond_chance = 0.3

var diamond: Diamond

var falling: bool = false

func _ready():
    super._ready()
    if randf() < diamond_chance:
        map_tile.changetype(Item.Type.APPLE_DIAMOND)
        diamond = Diamond.new(map_tile)
        get_parent().add_child.call_deferred(diamond)

func _process(_delta):
    if !falling:
        if map_tile.below().item.in_tunnel() or map_tile.item.in_tunnel():
            GameManager.queue.add(fall, GameTime.now() + (30.0 / (GameManager.level + 1)))
            falling = true

func fall(_timeritem):
    get_parent().add_child(FallingApple.new(map_tile.map, board_pos, Vector2i.DOWN, 0.03))
    if diamond:
        diamond.update_sprite()
        map_tile.changetype(Item.Type.DIAMOND)
        map_tile.node = diamond
    else:
        map_tile.node = self
        map_tile.rmv_obj()
    queue_free()
