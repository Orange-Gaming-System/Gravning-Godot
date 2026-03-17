class_name GrvAudio extends RefCounted

var sound_data: Dictionary[String, AudioStream] = {}

## Load the sound data from the sound folder in the theme, which should end with a slash (/).
func load_sound_data(path: String):
    sound_data.bomb_explode = load_sound_file(path, "bomb_explode.tres")
    sound_data.startup = load_sound_file(path, "startup.tres")

func load_sound_file(folder: String, file: String) -> AudioStream:
    var full_path = folder + file
    if FileAccess.file_exists(full_path):
        return load(full_path)
    else:
        return load("res://themes/default/sound/" + file)
