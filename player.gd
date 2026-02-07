@icon("res://Node Icons/node_2D/icon_character.png")
class_name Player extends MovingObj

## Holds the most recent input.
var last_input: String = "_null"
## Holds whether or not the input held in [member last_input] was sent during the current tick.
var input_from_tick: bool = false



## The list of actions accepted by the player node.
const accepted_actions: Array[StringName] = ["left", "right", "up", "down", "escape"]

func _ready():
	super._ready()
	GameManager.game_clock.wait_time = (0.15*grvFileLoader.levelcount)/(GameManager.level+grvFileLoader.levelcount)
	GameManager.game_clock.start()

# Input handler
func _input(event):
	for action in accepted_actions:
		if event.is_action(action):
			if Input.is_action_just_pressed(action):
				last_input = action
				input_from_tick = true

func _new_tick() -> void:
	board_pos = goal_pos
	var new_pos = board_pos
	if input_from_tick or Input.is_action_pressed(last_input):
		if last_input != "escape":
			# code for standard movement.
			
			# move new_pos in the input direction.
			match str(last_input):
				"left":
					new_pos.x -= 1
				"right":
					new_pos.x += 1
				"up":
					new_pos.y -= 1
				"down":
					new_pos.y += 1
			# get movement type at position.
			var move_type = GameManager.get_movement_type(new_pos, board_pos)
			# if our movement is blocked, don't move.
			match move_type:
				GameManager.MOVE_TYPE.DIG:
					GameManager.dig(new_pos)
				GameManager.MOVE_TYPE.BLOCKED:
					new_pos = board_pos
	start_pos = board_pos
	goal_pos = new_pos
	input_from_tick = false
