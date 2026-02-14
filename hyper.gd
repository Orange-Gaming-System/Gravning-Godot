class_name Hyper extends Collectible

func _ready():
    super._ready()
    play(map_tile.item.visual_str())
