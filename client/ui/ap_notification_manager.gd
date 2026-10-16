extends CanvasLayer

const NOTIFICATION_SCENE = preload("res://Levels/Components/collectable_notification.tscn")
const AP_NOTIFICATION_SCRIPT = preload("res://mods-unpacked/JLannoo-DesveladoAP/ui/ap_notification.gd")

var _queue: Array = []

func _ready() -> void:
	layer = 100
	
func notify(text: String, counter: String = '') -> void:
	# Scene needs to be in tree to render
	var n = NOTIFICATION_SCENE.instantiate()
	n.set_script(AP_NOTIFICATION_SCRIPT)
	add_child(n)
	
	n.show_message(text, counter)
