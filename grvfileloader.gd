extends Node

var gamecached = false
var gamecachefailure = ""
var levelcount: int = -1
var title = ""
var byline = ""
var author = ""
var mappaths = []

func cachegrvfile(path): # stores all the data about a game from the .grv file into variables for easy access.
	gamecached = false # game is not cached
	gamecachefailure = "" # caching has not failed
	var file = FileAccess.open(path, FileAccess.READ) # gets the .grv file
	var filecontent = file.get_as_text() # loads the contents of the file
	var game = filecontent.split("\n", false) # converts the file into an array, line by line
	var commands = [] # holds all the commands
	var args = [] # holds the arguements
	for line in game:
		# For every line, this loop splits it into commands and arguements.
		var linedata = line.split(" ", true, 1)
		commands.append(linedata[0])
		args.append(linedata[1])
	var titlepos = commands.find("title") # gets the position of the title in the array.
	if titlepos != -1: # if there is a title, set the title to it. else, says "No Title Added"
		title = args[titlepos].trim_prefix("\"").trim_suffix("\"")
	else:
		title = "No Title Added"
	var bylinepos = commands.find("byline") # repeat what just happened for the title but for the byline.
	if bylinepos != -1:
		byline = args[bylinepos].trim_prefix("\"").trim_suffix("\"")
	else: # the byline is set to blank when there is none.
		byline = ""
	var authorpos = commands.find("author") # repeat for the author.
	if authorpos != -1:
		author = args[authorpos].trim_prefix("\"").trim_suffix("\"")
	else: # author is set to "Unknown" when no author is specified.
		author = "Unknown"
	var levelcountpos = commands.find("levels") # get the level count position.
	if levelcountpos != -1:
		levelcount = int(args[levelcountpos]) # if there is one, store it.
		gamecached = true
	else:
		levelcount = -1 # else, return with an error.
		gamecachefailure = "nolevelcount"
		print("Game cache failed: No Level Count.")
		return
	mappaths.resize(levelcount) # set the size of the "mappaths" array to the level count.
	for n in commands.size(): # this loop runs for every line in the .grv file.
		var command = commands[n]
		if command != "map": # if the command does not specify a map, ignore this line.
			continue
		var arg = args[n]
		var mapargs = arg.split(" ", true, 1) # split the map into a map number and a map path.
		if "-" in mapargs[0]: # checks if this is for 1 map or a range of maps.
			var maprange = mapargs[0].split("-", false, 1) # if it is a range, determine the top and bottom.
			for map in int(maprange[1]) - int(maprange[0]) + 1: # for each map in the range, store them in their respective location in the array.
				map += int(maprange[0])
				mappaths[map-1] = "/".join([path.rsplit("/", true, 1)[0], mapargs[1].trim_prefix("\"").trim_suffix("\"")])
		else:
			mappaths[int(mapargs[0])-1] = "/".join([path.rsplit("/", true, 1)[0], mapargs[1].trim_prefix("\"").trim_suffix("\"")]) # if this is a single map, store its path in the correct location in the array.
	return # when debugging or testing, place a breakpoint here to check if the code executed correctly.

func loadlevelfile(level: int):
	var lvlpath = mappaths[level - 1]
	@warning_ignore("unused_variable")
	var lvlbytes = FileAccess.get_file_as_bytes(lvlpath)
	#loadgrvmap(lvlbytes)

func _ready():
	cachegrvfile("/home/erik/Grv Levels/The Digging Dead/game.grv")
	return
