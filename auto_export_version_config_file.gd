class_name Version extends "res://addons/AutoExportVersion/VersionProvider.gd"

static func version() -> Dictionary:
    var v = ProjectSettings.get_setting("application/config/version")
    if v:
        return JSON.parse_string(v)
    else:
        return get_git_version()

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
    var ver : Dictionary = get_git_version()
    ver.preset_version = get_export_preset_version()
    ver.preset_android_version_code = get_export_preset_android_version_code()
    ver.preset_android_version_name = get_export_preset_android_version_name()
    ver.debug = is_debug
    ver.path = path
    ver.flags = flags
    ver.features = features
    return JSON.stringify(ver)
