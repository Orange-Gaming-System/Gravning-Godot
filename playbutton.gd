extends Button

func _on_pressed():
    GameManager.prepare_game()
    $"../..".queue_free()
