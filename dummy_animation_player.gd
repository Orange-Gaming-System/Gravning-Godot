class_name DummyAnimPlayer extends AnimatedSprite2D

## A very simple object that is used to play animations separate from other objects.
##
## Mainly exists so that the clean-up process doesn't break.

func delete():
    queue_free()
