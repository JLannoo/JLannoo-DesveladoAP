extends Node

const MOD_DIR := "JLannoo-DesveladoAP"
const LOG_NAME := "JLannoo-DesveladoAP:Main"

var mod_dir_path: String = ""
var extensions_dir_path: String = ""

var player: Player

var ap_console: Window

const LEVEL_DISPLAY_NAME: Dictionary = {
	"ZONE1_1": "Castle 1",
	"ZONE1_2": "Castle 2",
	"RUN_1":   "Castle Boss",

	"ZONE2_1": "Sewers 1",
	"ZONE2_2": "Sewers 2",
	"ZONE2_3": "Sewers 3",
	"RUN_2":   "Sewers Boss",

	"ZONE3_1": "Caves 1",
	"ZONE3_2": "Caves 2",
	"ZONE3_3": "Caves 3",
	"RUN_3":   "Caves Boss",
}

@export var AP_NOTIFICATION_MANAGER = preload("res://mods-unpacked/JLannoo-DesveladoAP/ui/ap_notification_manager.gd")
var notification_manager: CanvasLayer

const BONUS_COLLECTABLE_EXT = preload("res://mods-unpacked/JLannoo-DesveladoAP/extensions/Levels/Components/bonus_collectable.gd")
const PLAYER_EXT = preload("res://mods-unpacked/JLannoo-DesveladoAP/extensions/Player/player.gd")

var first_map_found: bool = false

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	install_script_extensions()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Menus/main_menu_v2.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Menus/pause_menu.gd"))

	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Components/bonus_collectable.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Components/collectable_notification.gd"))

	# ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Engine/game_manager.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Engine/stage_manager.gd"))
	
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Components/switch.gd")) # Cover both the key_switch and ghost_switch
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Components/falling_platform.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Components/lamp_chandelier.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Levels/Components/ghost_wall.gd"))
	
	# ModLoaderMod.install_script_extension(extensions_dir_path.path_join("/Player/player.gd"))

func _ready() -> void:
	var tree = get_tree()
	tree.node_added.connect(_on_node_added)
	
	notification_manager = AP_NOTIFICATION_MANAGER.new()
	add_child(notification_manager)
	
	Console.add_command("notification", _trigger_notification, 2)
	Console.add_command("level_room", _move_to_level_room, 2)

	ModLoaderLog.info("Ready!", LOG_NAME)

	_try_ap_connect()

	Archipelago.on_attach_console.connect(_on_attach_console)

	Archipelago.connected.connect(_on_ap_connected)

func _on_node_added(node: Node) -> void:
	# Hook into room adding for catching all room IDs
	if node is Room:
		node.room_cleared.connect(_on_room_cleared.bind(node))

	# bonus_collectable are preloaded by StageManager and preload.tscn
	# so they are loaded before the extension is applied. 
	# We replace them manually.
	if node.scene_file_path.contains("bonus_collectable") and node.get_script() != BONUS_COLLECTABLE_EXT:
		# Replacing the script discards exported vars
		if "id" in node:
			var id = node.id
			node.set_script(BONUS_COLLECTABLE_EXT)
			node.id = id

	# Player has `class_name Player`; install_script_extension breaks it on Godot 4.2
	# ("hides a global script class").
	# We replace it manually.

	# Player has no exports and isn't _ready yet, so swapping the script here is safe.
	if node is Player and node.get_script() != PLAYER_EXT:
		node.set_script(PLAYER_EXT)

	if node is Player and not player:
		player = node
		if not player.died.is_connected(_on_player_died):
			player.died.connect(_on_player_died)

func _on_room_cleared(s: Room) -> void:
	if Archipelago.is_ap_connected():
		var current_stage = StageManager.current_stages_data.stages[StageManager.current_stage]
		var data = Archipelago.conn.get_gamedata_for_player()

		# Room index does not exist in-game. Work around with location name.
		var location_name = "%s - %s - Room Cleared" % [LEVEL_DISPLAY_NAME[current_stage.name.to_upper()], s.name]
		if current_stage.name.to_upper().contains("RUN"):
			location_name = "%s - Room Cleared" % [LEVEL_DISPLAY_NAME[current_stage.name.to_upper()]]

		Archipelago.collect_location(data.get_loc_id(location_name))

func _trigger_notification(text: String, count: String) -> void:
	notification_manager.notify(text, count)

func _move_to_level_room(level_id: String, room_id: String) -> void:
	Console.print_line("Moving to level %s" % [level_id])
	StageManager.go_to_stage(int(level_id))

	await get_tree().create_timer(1).timeout

	var level = get_node("/root/Level")
	level.console_move_to(room_id)
	Console.print_line("Moving to room %s" % [room_id])
	

func _on_player_died():
	if Archipelago.is_ap_connected() and Archipelago.is_deathlink():
		Archipelago.conn.send_deathlink()

func _try_ap_connect():
	Archipelago.ap_connect("localhost", "38281", "Desvelado")

func _on_attach_console():
	ap_console = get_node("/root/Archipelago/Console")
	
	# Don't disable input to the console while game is paused.
	ap_console.process_mode = Node.PROCESS_MODE_ALWAYS
	ap_console.tree_exited.connect(_on_close_console)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_close_console():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_ap_connected(_conn: ConnectionInfo, _json: Dictionary):
	Archipelago.conn.obtained_item.connect(_on_item_receive)
	Archipelago.conn.force_scout_all()

func _on_item_receive(item: NetworkItem):
	_handle_item_received(item)
	
func _handle_item_received(item: NetworkItem):
	# Mechanics are already handled by UnlockableComponent
	var item_name = item.get_name()
	
	if item_name.contains("Bonnie Bone"):
		_handle_bone_received(item)
		return

	elif item_name.contains("Map Part"):
		_handle_map_received(item)
		return

	elif item_name.contains("Unlock"):
		_handle_unlock_received(item)
		return
	

func _handle_bone_received(item: NetworkItem):
	var count = GameManager.count_collectables()
	GameManager.add_collectable(count+1)
	notification_manager.notify_ap_item(item, "%s / 15" % (count+1))

func _handle_map_received(item: NetworkItem):
	var zone_display_name = item.get_name().split(" Map Part")[0]
	var zone_name = LEVEL_DISPLAY_NAME.find_key(zone_display_name)
	
	var zone_id = -1
	var stages = StageManager.current_stages_data.stages
	for i in stages.size():
		if stages[i].name.to_upper() == zone_name:
			zone_id = i
			break

	if zone_id == -1:
		push_error("Received invalid map part")
		return

	StageManager.ap_add_map_part(zone_id)
	
	notification_manager.notify_ap_item(item)
	
	if not first_map_found:
		first_map_found = true
		StageManager.get_saved_stage(0).won = true
		MapMenu.toggle_map(true)

# Functional side of mechanic unlocks are handled by UnlockableComponent
func _handle_unlock_received(item: NetworkItem):
	notification_manager.notify_ap_item(item)
