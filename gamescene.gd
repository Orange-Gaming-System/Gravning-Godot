extends Node2D

var objects		: Node2D
var end_timer	: Timer

func _ready():
    objects = get_node("objects")
    end_timer = get_node("end_timer")
    end_timer.stop()
    GameManager.start_game()
