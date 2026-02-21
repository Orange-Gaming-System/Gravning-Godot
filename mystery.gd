@icon("res://Node Icons/node_2D/icon_chest.png")
class_name Mystery extends Collectible

func _ready():
    super._ready()
    animation_finished.connect(_animation_finished)

func _animation_finished():
    queue_free()

func collect():
    while true:
        var tlife = (6 - GameManager.lives) * 20
        var myst = randi_range(0, 1400 + tlife) - tlife
        if myst < 0:
            if GameManager.lives >= 6:
                continue
            GameManager.lives += 1
            GameManager.print_message("Treasure: Extra Life")
            break
        if myst < 150:
            var score = (randi_range(0, 200) + 100) * GameManager.level
            if score == 0:
                score = randi_range(0, 200) + 100
            GameManager.score += score
            GameManager.print_message("Treasure: " + str(score) + " points")
            break
        if myst < 350:
            var score = (randi_range(0, 800) + 400) * GameManager.level
            if score == 0:
                score = randi_range(0, 800) + 400
            GameManager.score += score
            GameManager.print_message("Treasure: " + str(score) + " points")
            break
        if myst < 400:
            var score = (randi_range(0, 2000) + 1000) * GameManager.level
            if score == 0:
                score = randi_range(0, 2000) + 1000
            GameManager.score += score
            GameManager.print_message("Treasure: " + str(score) + " points")
            break
        if myst < 470:
            GameManager.print_message("Treasure: End of Level")
            GameManager.has_won_level = true
            break
        if myst < 650:
            if GameManager.ghost_modifier == GameManager.GhostMod.FREEZE:
                continue
            GameManager.print_message("Treasure: Ghost freeze")
            GameManager.ghost_modifier = GameManager.GhostMod.FREEZE
            GameManager.queue.add(GameManager.unfreeze_ghosts, GameTime.now() + 32.0 + 60.0 * randf() + 8)
            break
        if myst < 790:
            var ammo = randi_range(0, 3) + 2
            GameManager.ammo += ammo
            GameManager.print_message("Treasure: " + str(ammo) + " extra shots")
            break
        if myst < 930:
            if map_tile.map.itemcount[Item.Type.BOMB] == 0:
                continue
            for bombpos in map_tile.map.items[Item.Type.BOMB]:
                map_tile.map.items[Item.Type.BOMB][bombpos].node.instant_detonate(GameTime.now() + 4)
            GameManager.print_message("Treasure: Bomb detonation... OOPS!")
            break
        if myst < 1060:
            GameManager.queue.add(map_tile.map.player.node.smash, GameTime.now() + 5)
            GameManager.print_message("Treasure: *** SMASH ***")
            break
        if myst < 1230:
            if GameManager.ghost_modifier == GameManager.GhostMod.SCARED:
                continue
            GameManager.print_message("Treasure: Scared ghosts")
            GameManager.ghost_modifier = GameManager.GhostMod.SCARED
            GameManager.queue.add(GameManager.unfreeze_ghosts, GameTime.now() + 80)
            break
        else:
            if GameManager.ghost_modifier != GameManager.GhostMod.NONE:
                continue
            GameManager.print_message("Treasure: Slow ghosts")
            GameManager.ghost_modifier = GameManager.GhostMod.SLOW
            GameManager.queue.add(GameManager.unslow_ghosts, GameTime.now() + 60)
            break
    play("default")
