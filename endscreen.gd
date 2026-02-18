extends Panel

func appear():
    visible = true
    self_modulate = GameManager.colors[GameManager.palette[1]]
