extends GridContainer
const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")
const APCredentials = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ap_files/connect_creds.gd")
const ConnectionInfo = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ap_files/connection_info.gd")


@onready var ipbox: LineEdit = $IP_Box
@onready var portbox: LineEdit = $Port_Box
@onready var slotbox: LineEdit = $Slot_Box
@onready var pwdbox: LineEdit = $Pwd_Box
@onready var errlbl: Label = $ErrorLabel

func _ready() -> void:
	AP.instance.creds.updated.connect(refresh_creds)
	refresh_creds(AP.instance.creds)
	AP.instance.connected.connect(func(_conn,_json): update_connection(true))
	AP.instance.disconnected.connect(func(): update_connection(false))
func refresh_creds(creds: APCredentials) -> void:
	ipbox.text = creds.ip
	portbox.text = creds.port
	slotbox.text = creds.slot
	pwdbox.text = creds.pwd

func update_connection(status: bool) -> void:
	ipbox.editable = not status
	portbox.editable = not status
	slotbox.editable = not status
	pwdbox.editable = not status
func try_connection() -> void:
	if AP.instance.is_not_connected():
		AP.instance.ap_connect(ipbox.text, portbox.text, slotbox.text, pwdbox.text)
		_connect_signals()

func kill_connection() -> void:
	AP.instance.ap_disconnect()

func _connect_signals() -> void:
	if not AP.instance.connected.is_connected(_on_connect_success):
		AP.instance.connected.connect(_on_connect_success)
	if not AP.instance.connectionrefused.is_connected(_on_connect_refused):
		AP.instance.connectionrefused.connect(_on_connect_refused)
func _disconnect_signals() -> void:
	AP.instance.connected.disconnect(_on_connect_success)
	AP.instance.connectionrefused.disconnect(_on_connect_refused)
func _on_connect_success(_conn: ConnectionInfo, _json: Dictionary) -> void:
	_disconnect_signals()
	errlbl.text = ""
func _on_connect_refused(_conn: ConnectionInfo, json: Dictionary) -> void:
	_disconnect_signals()
	errlbl.text = "ERROR: " + (", ".join(json.get("errors", ["Unknown"])))
