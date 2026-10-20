extends "res://Levels/Components/bonus_collectable.gd"

func collect():
	super()

	var collectable_num = GameManager.count_collectables()

	Archipelago.collect_location(collectable_num)
	
