@icon("res://Node Icons/node_2D/icon_bullet.png")
class_name Ammo extends Collectible

func collect():
    GameManager.ammo += 1
    super.collect()
