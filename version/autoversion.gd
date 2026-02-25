extends "res://addons/AutoExportVersion/VersionProvider.gd"

func get_version(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int):
    var v = load("res://version/gitversion.gd").version()
    print("Exporting version: ", v)
    return v
