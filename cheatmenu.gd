extends Window

func _on_close_requested():
    GameManager.resume()
    hide()

func _on_visibility_changed() -> void:
    if visible:
        $Panel/ScrollContainer/Control/leveljump_input.max_value = GameManager.grv_file.levelcount
        $Panel/ScrollContainer/Control/setshot_input.value = GameManager.ammo
        $Panel/ScrollContainer/Control/setpower_input.value = GameManager.power
        $Panel/ScrollContainer/Control/leveljump_input.value = GameManager.level + 1
        #$bgcolor.self_modulate = GameManager.colors[GameManager.palette[0]]


func _on_size_changed() -> void:
    $Panel.size = size
    $Panel/ScrollContainer.size = size

func instant_win():
    GameManager.level += GameManager.hyper.count(true) + 1
    GameManager.level_streak += 1
    if GameManager.jumpto > -1:
        GameManager.super_bonus()
        return
    for shot in GameManager.ammo:
        if randf() > 0.1:
            GameManager.ammo -= 1 # 10% chance to keep unused shots. (Really a 90% chance to lose each shot)
    GameManager.load_level()


func level_jump() -> void:
    GameManager.level = $Panel/ScrollContainer/Control/leveljump_input.value - 1
    for shot in GameManager.ammo:
        if randf() > 0.1:
            GameManager.ammo -= 1 # 10% chance to keep unused shots. (Really a 90% chance to lose each shot)
    GameManager.load_level()


func set_shots() -> void:
    GameManager.ammo = $Panel/ScrollContainer/Control/setshot_input.value


func set_power() -> void:
    GameManager.power = $Panel/ScrollContainer/Control/setpower_input.value

const mystery_numbers = [Mystery.forced_sentinal, -1, 100, 300, 375, 450, 600, 700, 900, 1000, 1200, 1300]

func give_mystery() -> void:
    var choice = $Panel/ScrollContainer/Control/mysteryselector.selected
    var forced = mystery_numbers[choice]
    _on_close_requested()
    var mystery = Mystery.new(GameManager.grvmap.player)
    GameManager.gamescene.get_node("objects").add_child(mystery)
    mystery.sprite_frames = GameManager.grvtheme.obj_frames[Item.Type.MYSTERY]
    mystery.collect(forced)
