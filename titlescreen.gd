extends Control

const background_color : Color = Color("#111635")

func _ready():
    RenderingServer.set_default_clear_color(background_color)
    $title_music_intro.stream = GameManager.audio.sound_data.title_intro
    $title_music_loop.stream = GameManager.audio.sound_data.title
    $title_music_intro.play()
    $tabs/Settings/settings_area/volume/slider.value = SettingsManager.volume
    volume_slider_changed(SettingsManager.volume)


func _on_title_music_finished() -> void:
    $title_music_loop.play()


# Main Page

func _on_play_pressed():
    GameManager.prepare_game(grvFile.new("res://levels/grv/grv.grv"))
    queue_free()

func _on_settings_pressed() -> void:
    $tabs.current_tab = 1


# Settings Page

func _on_settings_back():
    $tabs.current_tab = 0

func volume_slider_changed(value):
    SettingsManager.volume = value
    var percent = int(value * 100)
    $tabs/Settings/settings_area/volume/slider/percent_display.text = str(percent) + "%"
