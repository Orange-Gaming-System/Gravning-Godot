class_name Character extends MovingObj

func _ready():
    super._ready()
    var collision = preload("res://character_collisions.tscn").instantiate()
    add_child(collision)
    collision.area_entered.connect(Callable(self, "_collided"))

func _collided(_area):
    pass
