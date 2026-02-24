extends RefCounted

static func version():
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
        for sarg in ["author_date", "commit_date", "commit",
                     "describe", "subject"]:
            ver[sarg] = fields[i]
            i += 1
    if !ver:
        push_error("Failed to get version from git log. Make sure you have git installed and project is inside a valid git directory.")
    return ver
