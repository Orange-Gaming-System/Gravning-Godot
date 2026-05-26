extends Control

const background_color : Color = Color("#111635")

func _ready():
    RenderingServer.set_default_clear_color(background_color)
    $title_music_intro.stream = GameManager.audio.sound_data.title_intro
    $title_music_loop.stream = GameManager.audio.sound_data.title
    $title_music_intro.play()
    $tabs/Settings/settings_area/volume/slider.value = SettingsManager.volume
    volume_slider_changed(SettingsManager.volume)
    update_games_list()
    if OS.has_feature("web"):
        $tabs/Main/buttons/games.disabled = true
        $tabs/Main/buttons/games.tooltip_text = "Not available on web version."


func _on_title_music_finished() -> void:
    $title_music_loop.play()


# Main Page

func _on_play_pressed():
    GameManager.is_base_game = true
    GameManager.prepare_game(grvFile.new("res://levels/grv/grv.grv"))
    queue_free()

func _on_settings_pressed() -> void:
    $tabs.current_tab = 1

func _on_games_pressed() -> void:
    $tabs.current_tab = 2


# Settings Page

func _on_settings_back():
    $tabs.current_tab = 0

func volume_slider_changed(value):
    SettingsManager.volume = value
    var percent = int(value * 100)
    $tabs/Settings/settings_area/volume/slider/percent_display.text = str(percent) + "%"


# Games Page

func _on_games_back():
    $tabs.current_tab = 0

func _on_load_game():
    $tabs/Games/open_grv_file.popup_file_dialog()

func _on_game_loaded(path: String):
    if !SettingsManager.loaded_games.has(path):
        SettingsManager.loaded_games.append(path)
        update_games_list()
        SettingsManager.save_settings()

func update_games_list():
    print("Updating Games List")
    var games_list = SettingsManager.loaded_games
    for gametile in %game_list.get_children():
        gametile.queue_free()
    for game in games_list:
        var gametile = preload("res://game_tile.tscn").instantiate()
        gametile.game_path = game
        gametile.titlescreen = self
        %game_list.add_child(gametile)

func _on_open_editor_pressed() -> void:
    OS.create_process("grvedit", [])
