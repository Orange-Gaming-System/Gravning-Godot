class_name Hyper extends Collectible

func _ready():
    super._ready()
    play(map_tile.item.visual_str())

func collect():
    var uinode = GameManager.gamescene.get_node("UI/hyper_" + map_tile.item.visual_str())
    uinode.visible = true
    GameManager.hyper[map_tile.item.visual] = true
    super.collect()
