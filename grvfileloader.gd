@icon("res://Node Icons/node/icon_file.png")
class_name grv_File_Loader extends Node

## Holds the length of the current game in levels.
var levelcount: int = -1
## Holds the title of the current game.
var title = ""
## Holds the byline of the current game (sort of a subtitle).
var byline = ""
## Holds the author (or creator) of the current game.
var author = ""
## Holds the paths to all the levels in the current game. Empty (null) elements are allowed, and will use the default level instead.
var mappaths = []

## Parses the .grv file found at [param path], converting it into a format that the rest of the game can understand.
func parsegrvfile(path): # stores all the data about a game from the .grv file into variables for easy access.
    var file = FileAccess.open(path, FileAccess.READ) # gets the .grv file
    var filecontent = file.get_as_text() # loads the contents of the file
    var game = filecontent.split("\n", false) # converts the file into an array, line by line
    # Set all variables to their default value.
    levelcount = 75
    title = "Custom Game"
    byline = ""
    author = ""
    mappaths = []
    mappaths.resize(levelcount)
    # Loop through every line in the file.
    for line in game:
        # For every line, this loop splits it into commands and arguements.
        var linedata = line.split(" ", true, 1)
        # Check the command (forced lowercase to make the loop not case-sensitive) of this line, if it is not valid, ignore it.
        match linedata[0].to_lower():
            "title": # For title, byline, and author, set the respective variable and remove all quotation marks.
                title = linedata[1].trim_prefix("\"").trim_suffix("\"")
            "byline":
                byline = linedata[1].trim_prefix("\"").trim_suffix("\"")
            "author":
                author = linedata[1].trim_prefix("\"").trim_suffix("\"")
            "levels": # For levels, set the level count to the argument after converting it to an integer, and set the size of the mappaths array.
                levelcount = int(linedata[1])
                mappaths.resize(levelcount)
            "map": # For the map command, this code stores all the paths for the maps.
                var arg = linedata[1]
                var mapargs = arg.split(" ", true, 1) # split the map into a map number and a map path.
                if "-" in mapargs[0]: # checks if this is for 1 map or a range of maps.
                    var maprange = mapargs[0].split("-", false, 1) # if it is a range, determine the top and bottom.
                    for map in int(maprange[1]) - int(maprange[0]) + 1: # for each map in the range, store them in their respective location in the array.
                        map += int(maprange[0])
                        mappaths[map-1] = "/".join([path.rsplit("/", true, 1)[0], mapargs[1].trim_prefix("\"").trim_suffix("\"")])
                else:
                    mappaths[int(mapargs[0])-1] = "/".join([path.rsplit("/", true, 1)[0], mapargs[1].trim_prefix("\"").trim_suffix("\"")]) # if this is a single map, store its path in the correct location in the array.

func _ready():
    parsegrvfile("res://test/test.grv")
