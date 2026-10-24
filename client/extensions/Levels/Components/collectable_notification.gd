extends "res://Levels/Components/collectable_notification.gd"

# Disable vanilla notifications when Archipelago is active
func setup(is_first_collectable):
	if Archipelago.is_ap_connected():
		queue_free()
		return
	
	super(is_first_collectable)
