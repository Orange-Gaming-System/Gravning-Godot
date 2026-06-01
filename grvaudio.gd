class_name GrvAudio extends RefCounted

var sound_data: Dictionary[String, AudioStream] = {}

## Load the sound data from the sound folder in the theme, which should end with a slash (/).
func load_sound_data(path: String):
    sound_data.bomb_explode = load_sound_file(path, "bomb_explode.tres")
    sound_data.startup = load_sound_file(path, "startup.tres")
    sound_data.startup_reward = load_sound_file(path, "startup_reward.tres")
    sound_data.startup_boss = load_sound_file(path, "startup_boss.tres")
    sound_data.game_over = load_sound_file(path, "game_over.tres")
    sound_data.title = load_sound_file(path, "title.tres")
    sound_data.title_intro = load_sound_file(path, "title_intro.tres")
    sound_data.score_counter = load_sound_file(path, "score_counter.tres")
    sound_data.hs_start = load_sound_file(path, "hs_start.tres")
    sound_data.hs_loop = load_sound_file(path, "hs_loop.tres")
    sound_data.hs_end = load_sound_file(path, "hs_end.tres")
    sound_data.smash_countdown = load_sound_file(path, "smash_countdown.tres")
    sound_data.bomb_detonation_countdown = load_sound_file(path, "bomb_detonation_countdown.tres")

func load_sound_file(folder: String, file: String) -> AudioStream:
    var full_path = folder + file
    if FileAccess.file_exists(full_path):
        return load(full_path)
    else:
        return load("res://themes/default/sound/" + file)
