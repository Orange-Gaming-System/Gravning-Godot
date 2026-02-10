@icon("res://Node Icons/node/icon_file.png")
class_name grv_File_Loader extends Node

## Holds the length of the current game in levels.
var levelcount  : int = -1
## Holds the title of the current game.
var title       : String
## Holds the byline of the current game (sort of a subtitle).
var byline      : String
## Holds the author (or creator) of the current game.
var author      : String
## Holds the paths to all the levels in the current game. Empty (null) elements are allowed, and will use the default level instead.
var mappaths    : PackedStringArray
## Holds the first level (0-based) where quick escape is allowed.
var escape_lvl  : int = MAX_LEVELS

## The maximum number of allowed levels + 1.
const MAX_LEVELS: int = 65536

## Read a single line in a .grv file splitting it by tokens
var _token_regex : RegEx = RegEx.create_from_string("([^\\s\'\"]\\S*|\"(?:[^\"]|\"\")*\"|'(?:[^']|'')*')")
func read_line(file : FileAccess, strs : PackedStringArray) -> bool:
    strs.clear()
    var line : String = file.get_line()
    if (file.eof_reached()):
        return false
    for m in _token_regex.search_all(line):
        var s : String
        s = m.get_string(1)
        var c : String = (s[0]) if (s.length()) else ("")
        if (s.length() < 1 or c == "#"):
            break           # Empty or start of comment
        elif (s.length() >= 2 and (c == "'" or c == "\"")):
            s = s.substr(1, s.length()-2)
            s.replace(c+c, c)
        strs.append(s)
    return true

## Parses the .grv file found at [param path], converting it into a format that the rest of the game can understand.
func parsegrvfile(path : String): # stores all the data about a game from the .grv file into variables for easy access.
    var file : FileAccess = FileAccess.open(path, FileAccess.READ)
    var dir : String = path.get_base_dir()                       # File location
    # Set all variables to their default value.
    levelcount = 75
    title = "Custom Game"
    byline = ""
    author = ""
    mappaths.clear()
    mappaths.resize(levelcount)
    escape_lvl = MAX_LEVELS

    var next : int = 0      # For @ meaning continue after the last map number used

    # Loop through every line in the file.
    var linedata : PackedStringArray
    while read_line(file, linedata):
        # Check the command (forced lowercase to make the loop not case-sensitive) of this line, if it is not valid, ignore it.
        if linedata.size() < 2:
            continue

        print(linedata)

        match linedata[0].to_lower():
            "title":
                title = linedata[1]
            "byline":
                byline = linedata[1]
            "author":
                author = linedata[1]
            "levels": # For levels, set the level count to the argument after converting it to an integer, and set the size of the mappaths array.
                if (linedata[1].is_valid_int()):
                    var lc : int = int(linedata[1])
                    if (lc > 0 and lc < MAX_LEVELS):
                        levelcount = lc
                        mappaths.resize(levelcount)
            "escape":
                if (linedata[1].is_valid_int()):
                    escape_lvl = int(linedata[1]) - 1
            "map": # For the map command, this code stores all the paths for the maps.
                if (linedata.size() < 3):
                    continue

                var lo : int = 0                # Inclusive, 0-based
                var hi : int = levelcount       # Exclusive, 0-based
                var nm : String = linedata[1]
                var plus : bool = false
                var maprange : PackedStringArray = nm.split("-", true, 1)
                if maprange.size() == 1:
                    maprange = nm.split("+", true, 1)
                    plus = maprange.size() > 1
                if maprange[0].is_valid_int():
                    lo = int(maprange[0]) - 1
                elif maprange[0] == "@":
                    lo = next
                if maprange.size() == 1:
                    hi = lo + 1
                elif maprange[1].is_valid_int():
                    hi = int(maprange[1])
                    if plus:
                        hi += lo

                if (lo < 0):
                    lo = 0
                if (hi > levelcount):
                    hi = levelcount
                if (lo >= hi):
                    continue        # Empty range

                var mappath : String = linedata[2]
                if mappath == "*":          # Syntax used by C version
                    mappath = ""            # Revert to default
                elif mappath.is_relative_path():
                    mappath = dir.path_join(mappath)
                for map in range(lo, hi):
                    mappaths[map] = mappath
                next = hi
    file.close()

func get_level_path(level):
    if mappaths[level] == "":
        return get_level_path(level - 1)
    return mappaths[level]

func _ready():
    parsegrvfile("res://test/test.grv")
