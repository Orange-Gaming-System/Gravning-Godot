extends Window

func _on_close_requested():
    GameManager.resume()
    hide()

func _on_visibility_changed() -> void:
    if visible:
        $Panel/ScrollContainer/Control/setshot_input.value = GameManager.ammo
        $Panel/ScrollContainer/Control/leveljump_input.value = GameManager.level

func _ready():
    $Panel/ScrollContainer/Control/leveljump_input.max_value = grvFileLoader.levelcount

func _on_size_changed() -> void:
    $Panel.size = size
    $Panel/ScrollContainer.size = size

func instant_win():
    GameManager.load_next_level()


func level_jump() -> void:
    GameManager.level = $Panel/ScrollContainer/Control/leveljump_input.value - 2
    GameManager.load_next_level()


func set_shots() -> void:
    GameManager.ammo = $Panel/ScrollContainer/Control/setshot_input.value
