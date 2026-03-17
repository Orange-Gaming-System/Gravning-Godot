extends AudioStreamPlayer

func _ready() -> void:
    GameManager.global_sound = self

func play_sound(new_stream: AudioStream):
    stream = new_stream
    play()
