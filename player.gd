extends CharacterBody2D

func _ready():
	%game_clock.wait_time = (0.15*grvFileLoader.levelcount)/(GameManager.level+grvFileLoader.levelcount)
	%game_clock.start()


func _on_game_clock_tick() -> void:
	print("clock!")
