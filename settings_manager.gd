extends Node

var settings: GrvSettings

var volume: float:
    set(value):
        settings.volume = value
        update_settings()

    get():
        return settings.volume

var loaded_games_list: LoadedGamesList

var loaded_games: Array[String]:
    set(value):
        loaded_games_list.loaded_games = value

    get():
        return loaded_games_list.loaded_games

func _ready():
    load_settings()

func update_settings():
    AudioServer.set_bus_volume_db(0, linear_to_db(volume))
    save_settings()

func load_settings():
    if ResourceLoader.exists("user://settings.tres"):
        settings = load("user://settings.tres")
    else:
        settings = GrvSettings.new()
    if ResourceLoader.exists("user://loaded_games.tres"):
        loaded_games_list = load("user://loaded_games.tres")
    else:
        loaded_games_list = LoadedGamesList.new()
    update_settings()

func save_settings():
    ResourceSaver.save(settings, "user://settings.tres")
    ResourceSaver.save(loaded_games_list, "user://loaded_games.tres")
