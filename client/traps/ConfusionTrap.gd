class_name ConfusionTrap
extends Trap

@onready var player: Player = get_node("/root/Level/Player")

var ACTIONS = [
	"move_right",
	"move_left",
	"move_up",
	"move_down",
	"jump",
	"dash",
]

var ACTION_EVENT_MAP = {}

func _ready():
	name = "Confusion Trap"
	
	for action in ACTIONS:
		var events = InputMap.action_get_events(action)
		ACTION_EVENT_MAP[action] = events

	super()

func effect():
	var available_actions = ACTION_EVENT_MAP.duplicate()

	for action_name in ACTIONS:
		var replacement_key = available_actions.keys().pick_random()
		var replacement = available_actions[replacement_key]
		
		InputMap.action_erase_events(action_name)

		for event in replacement:
			InputMap.action_add_event(action_name, event)

		available_actions.erase(replacement_key)

	var new_action_event_map = {}
	for action in ACTIONS:
		var events = InputMap.action_get_events(action)
		new_action_event_map[action] = events

	if player:
		player.modulate = Color("#8400ff")

func undo_effect():
	for action_name in ACTIONS:
		InputMap.action_erase_events(action_name)

		var action = ACTION_EVENT_MAP[action_name]

		for event in action:
			InputMap.action_add_event(action_name, event)

	if player:
		player.modulate = Color(1, 1, 1)

	queue_free()
