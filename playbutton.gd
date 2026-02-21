extends Button

func _on_pressed():
    GameManager.gamescene = preload("res://game.tscn").instantiate()
    GameManager.level = 0
    GameManager.level_streak = 0
    GameManager.ammo = 0
    GameManager.score = 0
    GameManager.lives = 3
    GameManager.power = 0
    get_tree().get_root().add_child.call_deferred(GameManager.gamescene)
    $"../..".queue_free()
