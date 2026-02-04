extends CharacterBody2D

## Holds the most recent input.
var last_input: String = "_null"
## Holds whether or not the input held in [member last_input] was sent during the current tick.
var input_from_tick: bool = false

## Holds the current player position in tiles. Is floating point to avoid snappy movement.
@export var board_pos: Vector2

## Holds the board position of the player at the start of the tick.
var start_pos: Vector2
## Holds the board position the player is currently moving to.
var goal_pos: Vector2

## The list of actions accepted by the player node.
const accepted_actions: Array[StringName] = ["left", "right", "up", "down", "escape"]

func _ready():
	%game_clock.wait_time = (0.15*grvFileLoader.levelcount)/(GameManager.level+grvFileLoader.levelcount)
	%game_clock.start()
	position = board_pos * 16
	goal_pos = board_pos

func _process(_delta):
	board_pos = lerp(start_pos, goal_pos, %game_clock.time_ratio)
	position = board_pos * 16

# Input handler
func _input(event):
	for action in accepted_actions:
		if event.is_action(action):
			if Input.is_action_just_pressed(action):
				last_input = action
				input_from_tick = true

func _on_game_clock_tick() -> void:
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
			if move_type == GameManager.MOVE_TYPE.BLOCKED:
				new_pos = board_pos
	start_pos = board_pos
	goal_pos = new_pos
	input_from_tick = false
