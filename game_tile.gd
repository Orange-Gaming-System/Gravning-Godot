extends Panel

var game_path: String

var game_file: grvFile

var titlescreen: Node

var index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_file = grvFile.new(game_path)
    $icon_bg/icon.texture = game_file.icon
    $title.text = game_file.meta.title
    $byline.text = game_file.meta.byline
    $author.text = game_file.meta.author_prefix + game_file.meta.author
    $reorder_box.hide()
    $confirm_button.hide()
    index = SettingsManager.loaded_games.find(game_path)
    if game_path.begins_with("res://"):
        $open_folder_button.hide()
        $delete_button.hide()

func _on_play_button_pressed() -> void:
    if game_path == "res://levels/grv/grv.grv":
        GameManager.is_base_game = true
    else:
        GameManager.is_base_game = false
    GameManager.prepare_game(game_file)
    titlescreen.queue_free()


func _on_open_folder_button_pressed() -> void:
    OS.shell_show_in_file_manager(game_path.get_base_dir())


func _on_delete_button_pressed() -> void:
    SettingsManager.loaded_games.remove_at(index)
    SettingsManager.save_settings()
    titlescreen.update_games_list()


func _on_reorder_button_pressed() -> void:
    $reorder_button.hide()
    $open_folder_button.hide()
    $play_button.hide()
    $delete_button.hide()
    $reorder_box.show()
    $confirm_button.show()
    $reorder_box.grab_focus()
    $reorder_box.value = index
    $reorder_box.min_value = 0
    $reorder_box.max_value = SettingsManager.loaded_games.size() - 1


func _on_reorder_confirmed() -> void:
    if $reorder_box.value == index:
        $reorder_button.show()
        $open_folder_button.show()
        $play_button.show()
        $delete_button.show()
        $reorder_box.hide()
        $confirm_button.hide()
    else:
        SettingsManager.loaded_games.remove_at(index)
        SettingsManager.loaded_games.insert($reorder_box.value, game_path)
        SettingsManager.save_settings()
        titlescreen.update_games_list()
