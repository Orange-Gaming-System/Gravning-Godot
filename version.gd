extends Label

func _ready():
    text = Version.version().describe
