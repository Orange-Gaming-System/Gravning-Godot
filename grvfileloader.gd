extends Node

var gamecached = false
var levelcount: int = -1
var title = ""
var byline = ""
var author = ""
var mappaths = []

func cachegrvfile(path): # stores all the data about a game from the .grv file into variables for easy access.
	gamecached = true # game is cached
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
						mappaths[map-1] = "/".join([path.trim_suffix("/"), mapargs[1].trim_prefix("\"").trim_suffix("\"")])
				else:
					mappaths[int(mapargs[0])-1] = "/".join([path.trim_suffix("/"), mapargs[1].trim_prefix("\"").trim_suffix("\"")]) # if this is a single map, store its path in the correct location in the array.

func loadlevelfile(level: int):
	var lvlpath = mappaths[level - 1]
	@warning_ignore("unused_variable")
	var lvlbytes = FileAccess.get_file_as_bytes(lvlpath)
	#loadgrvmap(lvlbytes)

func _ready():
	cachegrvfile("/home/erik/Grv Levels/The Digging Dead/game.grv")
	return
