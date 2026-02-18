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
            print("Treasure: Extra Life")
            break
        if myst < 150:
            var score = (randi_range(0, 200) + 100) * GameManager.level
            if score == 0:
                score = randi_range(0, 200) + 100
            GameManager.score += score
            print("Treasure: " + str(score) + " points")
            break
        if myst < 350:
            var score = (randi_range(0, 800) + 400) * GameManager.level
            if score == 0:
                score = randi_range(0, 800) + 400
            GameManager.score += score
            print("Treasure: " + str(score) + " points")
            break
        if myst < 400:
            var score = (randi_range(0, 2000) + 1000) * GameManager.level
            if score == 0:
                score = randi_range(0, 2000) + 1000
            GameManager.score += score
            print("Treasure: " + str(score) + " points")
            break
        if myst < 470:
            print("Treasure: End of Level")
            GameManager.has_won_level = true
            break
        if myst < 650:
            print("Treasure: Ghost Freeze (WIP)")
            break
        if myst < 790:
            var ammo = randi_range(0, 3) + 2
            GameManager.ammo += ammo
            print("Treasure: " + str(ammo) + " extra shots")
            break
        if myst < 930:
            if map_tile.map.itemcount[Item.Type.BOMB] == 0:
                continue
            for bombpos in map_tile.map.items[Item.Type.BOMB]:
                map_tile.map.items[Item.Type.BOMB][bombpos].node.instant_detonate(GameTime.now() + 4)
            print("Treasure: Bomb detonation... OOPS!")
            break
        if myst < 1060:
            GameManager.queue.add(map_tile.map.player.node.smash, GameTime.now() + 5)
            print("Treasure: *** SMASH ***")
            break
        if myst < 1230:
            print("Treasure: Scared Ghosts (WIP)")
            break
        else:
            print("Treasure: Slow Ghosts (WIP)")
            break
    play("default")
