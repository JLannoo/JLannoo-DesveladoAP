extends "res://Levels/Menus/pause_menu.gd"

func _ready() -> void:
	super()

	var menu_item_container = $GUI/VBoxContainer

	# to visually separate console button
	var margin = MarginContainer.new()
	margin.custom_minimum_size = Vector2(0,50)
	
	var button = menu_item_container.get_child(-1).duplicate()

	button.text = "Archipelago Console"
	for conn in button.pressed.get_connections():
		button.pressed.disconnect(conn.callable)

	button.pressed.connect(_on_ap_settings_pressed)
	button.focus_entered.connect(button_focused)

	menu_item_container.add_child(margin)
	menu_item_container.add_child(button)

func _on_ap_settings_pressed():
	Archipelago.open_console()
