extends "res://Levels/Menus/main_menu_v2.gd"

func _ready() -> void:
	super()

	var menu_item_container = $HBoxContainer/VBoxContainer
	var selected = $HBoxContainer/Selected
	
	var menu_item = menu_item_container.get_child(-2).duplicate()
	var button = menu_item.get_child(0)

	button.text = "Archipelago Console"
	for conn in button.pressed.get_connections():
		button.pressed.disconnect(conn.callable)

	button.pressed.connect(_on_ap_settings_pressed)
	button.focus_entered.connect(selected.button_focused)

	menu_item_container.add_child(menu_item)

func _on_ap_settings_pressed():
	Archipelago.open_console()
