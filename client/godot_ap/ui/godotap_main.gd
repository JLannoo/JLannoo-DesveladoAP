extends ColorRect
const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")
const APCredentials = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ap_files/connect_creds.gd")
const GodotAPMain = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ui/godotap_main.gd")
const Version = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ap_files/version.gd")

## Directly opens the CommonClient Console in the current SceneTree
## Used for standalone client applications

func _ready():
	if OS.is_debug_build():
		AP.instance.cmd_manager.debug_hidden = false

	AP.instance.AP_CLIENT_VERSION = Version.val(0,1,0) # GodotAP CommonClient version
	AP.log(AP.instance.AP_CLIENT_VERSION)
	AP.instance.set_tags(["TextOnly"])
	AP.instance.AP_ITEM_HANDLING = AP.instance.ItemHandling.ALL
	AP.instance.creds.updated.connect(GodotAPMain.save_connection)
	GodotAPMain.load_connection()

	if AP.instance.output_console:
		AP.instance.close_console()
	get_window().min_size = Vector2(750,400)
	get_window().title = "AP Text Client"
	AP.instance.load_packed_console_as_scene(get_tree(), load("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ui/common_client.tscn"))

static func load_connection():
	var conn_info_file: FileAccess = FileAccess.open("user://ap/connection.dat", FileAccess.READ)
	if not conn_info_file: return
	var ip = conn_info_file.get_line()
	var port = conn_info_file.get_line()
	var slot = conn_info_file.get_line()
	AP.instance.creds.update(ip, port, slot, "")
	conn_info_file.close()
static func save_connection(creds: APCredentials):
	DirAccess.make_dir_recursive_absolute("user://ap/")
	var conn_info_file: FileAccess = FileAccess.open("user://ap/connection.dat", FileAccess.WRITE)
	if not conn_info_file: return
	conn_info_file.store_line(creds.ip)
	conn_info_file.store_line(creds.port)
	conn_info_file.store_line(creds.slot)
	conn_info_file.close()
