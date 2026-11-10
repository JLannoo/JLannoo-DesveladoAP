extends "res://Levels/Components/collectable_notification.gd"

const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")

# Disable vanilla notifications when Archipelago is active
func setup(is_first_collectable):
	if AP.instance.is_ap_connected():
		queue_free()
		return
	
	super(is_first_collectable)
