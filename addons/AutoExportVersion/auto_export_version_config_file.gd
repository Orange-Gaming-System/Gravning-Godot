class_name AutoVersion extends "res://addons/AutoExportVersion/VersionProvider.gd"

static var _version : Dictionary

static func version() -> Dictionary:
    if _version:
        return _version
    var v = ProjectSettings.get_setting("application/config/version")
    if v:
        _version = JSON.parse_string(v)
    else:
        _version = get_git_version()
    return _version

static func get_git_version() -> Dictionary:
    var ver : Dictionary = { }
    var output : Array
    OS.execute("git",
        PackedStringArray(["log", "--max-count=1",
        r"--pretty=tformat:%at%n%ct%n%ai%n%ci%n%H%n%(describe:abbrev=6)%n%s"]),
        output)
    if !output.is_empty():
        var fields = output[0].split("\n")
        var i = 0
        for iarg in ["author_time", "commit_time"]:
            ver[iarg] = int(fields[i])
            i += 1
        for sarg in ["author_date", "commit_date", "commit", "describe", "subject"]:
            ver[sarg] = fields[i]
            i += 1
    if !ver:
        push_error("Failed to get version from git log. Make sure you have git installed and project is inside a valid git directory.")
    return ver

## Used on export
func get_version(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> String:
    print("getting version")
    var ver : Dictionary = get_git_version()
    ver.debug = is_debug
    ver.path = path
    ver.flags = flags
    ver.features = features
    return JSON.stringify(ver)
