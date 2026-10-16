extends "res://Levels/Menus/pause_menu.gd"

func _ready() -> void:
	super()

	var menu_item_container = $GUI/VBoxContainer
	
	var button = menu_item_container.get_child(-1).duplicate()

	button.text = "Archipelago Console"
	for conn in button.pressed.get_connections():
		button.pressed.disconnect(conn.callable)

	button.pressed.connect(_on_ap_settings_pressed)

	menu_item_container.add_child(button)

func _on_ap_settings_pressed():
	var ap = get_node("/root/Archipelago")
	if not ap:
		ModLoaderLog.error("Could not find global archipelago instance", "main_menu_v2.gd")

	ap.open_console()
