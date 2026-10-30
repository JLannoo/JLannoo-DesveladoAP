extends CanvasLayer

const NOTIFICATION_SCENE = "res://Levels/Components/collectable_notification.tscn"
const AP_NOTIFICATION_SCRIPT = preload("res://mods-unpacked/JLannoo-DesveladoAP/ui/ap_notification.gd")

var queue: Array[Notification] = []
var queue_waiting: bool = false

signal enqueued
signal released

class Notification:
	var scene: Control
	var text: String
	var counter: String = ""

func _ready() -> void:
	layer = 100

	enqueued.connect(_on_enqueued)
	released.connect(_on_released)

func create_scene() -> AP_NOTIFICATION_SCRIPT:
	var scene: Control = load(NOTIFICATION_SCENE).instantiate()

	scene.set_script(AP_NOTIFICATION_SCRIPT)

	return scene
	
func notify(text: String, counter: String = '') -> void:
	var scene = create_scene()

	var n = Notification.new()
	n.scene = scene
	n.text = text
	n.counter = counter

	queue.append(n)	
	enqueued.emit()

func notify_ap_item(item: NetworkItem, counter = ''):
	if item.is_local():
		notify("You found your %s" % item.get_name(), counter)
	else:
		notify("Received %s from %s" % [
			item.get_name(), 
			Archipelago.conn.get_player_name(item.src_player_id)
		], counter)


func _show_first():
	var n = queue.pop_front()
	if not n: return

	add_child(n.scene)
	queue_waiting = true

	n.scene.get_node("Timer").timeout.connect(func(): 
		queue_waiting = false
		released.emit()
	)

	n.scene.show_message(n.text, n.counter)

func _on_enqueued():
	if queue_waiting: return
	_show_first()
	
func _on_released():
	enqueued.emit()
