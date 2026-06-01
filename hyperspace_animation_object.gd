class_name HyperspaceAnimationObject extends AnimatedSprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var speed = $"..".object_speed
    position.z += speed * delta
    if speed > 0:
        if position.z >= $"..".object_destroy:
            queue_free()
    else:
        if position.z <= $"..".object_destroy:
            queue_free()
