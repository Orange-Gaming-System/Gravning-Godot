extends Control

const background_color : Color = Color("#111635")

func _ready():
    RenderingServer.set_default_clear_color(background_color)

func _on_play_pressed():
    GameManager.prepare_game()
    queue_free()
