class_name RelightTrap
extends Trap

@onready var level = get_node("/root/Level")

func _ready():
	name = "Relight Trap"
	super()

func effect():
	if not level: return

	var lamps_node: Node2D = level.lamps_node
	var lamps = lamps_node.get_children()
	lamps.shuffle()

	for lamp in lamps:
		if not lamp.is_on:
			lamp.is_on = true
			lamp.display_init()
			break
