extends CanvasLayer

const NOTIFICATION_SCENE = "res://Levels/Components/collectable_notification.tscn"
const AP_NOTIFICATION_SCRIPT = preload("res://mods-unpacked/JLannoo-DesveladoAP/ui/ap_notification.gd")

var _queue: Array = []

func _ready() -> void:
	layer = 100
	
func notify(text: String, counter: String = '') -> void:
	# Scene needs to be in tree to render
	var scene = load(NOTIFICATION_SCENE)
	var n = scene.instantiate()
	n.set_script(AP_NOTIFICATION_SCRIPT)
	add_child(n)
	
	n.show_message(text, counter)

func notify_ap_item(item: NetworkItem, counter = ''):
	if item.is_local():
		notify("You found your %s" % item.get_name(), counter)
	else:
		notify("Received %s from %s" % [
			item.get_name(), 
			Archipelago.conn.get_player_name(item.src_player_id)
		], counter)
