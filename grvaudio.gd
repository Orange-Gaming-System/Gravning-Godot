class_name GrvAudio extends RefCounted

var sound_data: Dictionary[String, AudioStream] = {}

## Load the sound data from the sound folder in the theme, which should end with a slash (/).
func load_sound_data(path: String):
    sound_data.bomb_explode = load(path + "bomb_explode.tres")
