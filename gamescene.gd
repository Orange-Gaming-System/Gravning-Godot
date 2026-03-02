extends Node2D

var grvmap: GrvMap

func _ready():
    GameManager.load_level()
    grvmap = GameManager.grvmap
