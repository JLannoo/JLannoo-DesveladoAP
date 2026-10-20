extends Node

const MOD_DIR := "JLannoo-DesveladoAP"
const LOG_NAME := "JLannoo-DesveladoAP:Main"

var mod_dir_path: String = ""
var extensions_dir_path: String = ""

var cleared_rooms: Dictionary = {}

var player: Player

var ap_console: Window

@export var AP_NOTIFICATION_MANAGER = preload("res://mods-unpacked/JLannoo-DesveladoAP/ui/ap_notification_manager.gd")
var notification_manager: CanvasLayer

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
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

	ModLoaderLog.info("Ready!", LOG_NAME)

	ModLoaderLog.info("Ready!", GODOTMODDING_EXAMPLEMOD_LOG_NAME)

	Archipelago.on_attach_console.connect(_on_attach_console)

func _on_node_added(node: Node) -> void:
	# Hook into room adding for catching all room IDs
	if node is Room:
		node.room_cleared.connect(_on_room_cleared.bind(node))

	if node is Player and not player:
		player = node
		if not player.died.is_connected(_on_player_died):
			player.died.connect(_on_player_died)

func _on_room_cleared(s) -> void:
	if !cleared_rooms.has(s.name):
		cleared_rooms[s.name] = true
		ModLoaderLog.info("Received room clear!. %s" % [s], LOG_NAME)

func _trigger_notification(text: String, count: String) -> void:
	notification_manager.notify(text, count)

func _on_player_died():
	Archipelago.send_deathlink()

func _on_attach_console():
	ap_console = get_node("/root/Archipelago/Console")
	
	# Don't disable input to the console while game is paused.
	ap_console.process_mode = Node.PROCESS_MODE_ALWAYS
	ap_console.tree_exited.connect(_on_close_console)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_close_console():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
