extends Control

const background_color : Color = Color("#111635")

func _ready():
    RenderingServer.set_default_clear_color(background_color)
    $title_music_intro.stream = GameManager.audio.sound_data.title_intro
    $title_music_loop.stream = GameManager.audio.sound_data.title
    $title_music_intro.play()

func _on_play_pressed():
    GameManager.prepare_game()
    queue_free()


func _on_title_music_finished() -> void:
    $title_music_loop.play()
