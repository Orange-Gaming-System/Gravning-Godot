extends Panel

var game_path: String

var game_file: grvFile

var titlescreen: Node

func _init():
    print("Game Tile Loaded!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    print("Game Tile Added to Scene!")
    game_file = grvFile.new(game_path)
    $icon_bg/icon.texture = game_file.icon
    $title.text = game_file.meta.title
    $byline.text = game_file.meta.byline
    $author.text = game_file.meta.author_prefix + game_file.meta.author

func _on_play_button_pressed() -> void:
    GameManager.prepare_game(game_file)
    titlescreen.queue_free()
