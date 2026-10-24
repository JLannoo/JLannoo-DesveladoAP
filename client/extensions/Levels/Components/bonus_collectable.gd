extends "res://Levels/Components/bonus_collectable.gd"

func collect():
	# Patch bug in game:
	# One of the bones should have id 7, but instead it has a -1 assigned.
	if id == -1:
		id = 7

	super()

	var collectable_num = GameManager.count_collectables()
	Archipelago.collect_location(collectable_num)
	
