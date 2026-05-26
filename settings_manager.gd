extends Node

var settings: GrvSettings

var volume: float:
    set(value):
        settings.volume = value
        update_settings()

    get():
        return settings.volume

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
    update_settings()

func save_settings():
    ResourceSaver.save(settings, "user://settings.tres")
