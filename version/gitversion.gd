extends RefCounted

const gitinfo : Array = [
    [ "author_time", "int", "%at" ],
    [ "author_date", "str", "%ai" ],
    [ "commit_time", "int", "%ct" ],
    [ "commit_date", "str", "%ci" ],
    [ "commit",      "str", "%H" ],
    [ "describe",    "str", "%(describe:abbrev=6)" ],
    [ "subject",     "str", "%s" ]
]

static func version():
    var ver : Dictionary = { }
    var output : Array
    var fmt : String = "--pretty=tformat:"
    for gi in gitinfo:
        fmt += gi[2] + "%n"
    OS.execute("git", PackedStringArray(["log", "--max-count=1", fmt]), output)
    if !output.is_empty():
        var fields : PackedStringArray = output[0].split("\n")
        for i in gitinfo.size():
            var field : String
            if i < fields.size():
                field = fields[i]
            var gi = gitinfo[i]
            match gi[1]:
                "int":
                    if field.is_valid_int():
                        ver[gi[0]] = int(field)
                "str":
                    ver[gi[0]] = field

    if !ver:
        push_error("Failed to get version from git log. Make sure you have git installed and project is inside a valid git directory.")
    return ver
