@icon("res://Node Icons/node_2D/icon_trophy.png")
class_name Cherry extends Collectible

func collect():
    GameManager.score += GameManager.level + 1
    super.collect()
