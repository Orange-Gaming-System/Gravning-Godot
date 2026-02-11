class_name BonusCoin extends Collectible

var current_bonus_state: bool = true

func _new_tick():
    if current_bonus_state != GameManager.bonus:
        current_bonus_state = GameManager.bonus
        var current_frame = frame
        if current_bonus_state:
            play("gold")
        else:
            play("silver")
        frame = current_frame

func collect():
    if GameManager.bonus:
        if GameManager.level != 0:
            GameManager.score += int(GameManager.level * exp(6.0 * randf() + 3.0))
        else:
            GameManager.score += int(exp(6.0 * randf() + 3.0))
    super.collect()
