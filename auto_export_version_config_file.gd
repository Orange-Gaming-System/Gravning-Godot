class_name Version extends "res://addons/AutoExportVersion/VersionProvider.gd"

static func version() -> Dictionary:
    var v = ProjectSettings.get_setting("application/config/version")
    if v:
        return JSON.parse_string(v)
    else:
        return get_git_version()

static func get_git_version() -> Dictionary:
    var ver = null
    var output : Array
    OS.execute("git", PackedStringArray(["log", "--max-count=1",
        r"--pretty=format:{\"commit\":\"%H\",\"author_time\":%at,\"author_date\":\"%ai\",\"commit_time\":%ct,\"commit_date\":\"%ci\",\"describe\":\"%(describe:abbrev=7)\",\"subject\":\"%s\"}%n"]), output)
    if !output.is_empty():
        print(output[0])
        ver = JSON.parse_string(output[0])
    if !ver:
        push_error("Failed to get version from git log. Make sure you have git installed and project is inside a valid git directory.")
        return { }
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
