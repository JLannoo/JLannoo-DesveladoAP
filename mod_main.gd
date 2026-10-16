extends Node

const GODOTMODDING_EXAMPLEMOD_DIR := "JLannoo-DesveladoAP"
const GODOTMODDING_EXAMPLEMOD_LOG_NAME := "JLannoo-DesveladoAP:Main"

var mod_dir_path := ""
var extensions_dir_path := ""

var cleared_rooms := {}

@export var AP_NOTIFICATION_MANAGER = preload("res://mods-unpacked/JLannoo-DesveladoAP/ui/ap_notification_manager.gd")
var notification_manager: CanvasLayer

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(GODOTMODDING_EXAMPLEMOD_DIR)
	install_script_extensions()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Menus/main_menu_v2.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Menus/pause_menu.gd"))

func _ready() -> void:
	var tree = get_tree()
	tree.node_added.connect(_on_node_added)
	
	notification_manager = AP_NOTIFICATION_MANAGER.new()
	add_child(notification_manager)
	
	Console.add_command("notification", _trigger_notification, 2)
	Console.add_command("test", func(): notification_manager.notify("Hello from DesveladoAP", "6/9"))

	ModLoaderLog.info("Ready!", GODOTMODDING_EXAMPLEMOD_LOG_NAME)

func _on_node_added(node: Node) -> void:
	# Hook into room adding for catching all room IDs
	if node is Room:
		node.room_cleared.connect(_on_room_cleared.bind(node))

func _on_room_cleared(s) -> void:
	if !cleared_rooms.has(s.name):
		cleared_rooms[s.name] = true
		ModLoaderLog.info("Received room clear!. %s" % [s], GODOTMODDING_EXAMPLEMOD_LOG_NAME)

func _trigger_notification(text: String, count: String) -> void:
	notification_manager.notify(text, count)
