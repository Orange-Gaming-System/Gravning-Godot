class_name Version extends Object

static var _version : Dictionary

const providers : PackedStringArray = [
    "res://version/gitversion.gd",
    "res://version/exported.gd"
    ]

static func version() -> Dictionary:
    if _version:
        return _version
    for path in providers:
        if ResourceLoader.exists(path):
            var provider = load(path)
            _version = provider.version()
            if _version:
                break
    return _version
