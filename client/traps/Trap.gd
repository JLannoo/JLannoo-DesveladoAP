extends Node2D

signal trap_triggered
signal trap_done

var is_active: bool = false
var timer: Timer = Timer.new()

var notification_manager: CanvasLayer

func _ready():
	add_child(timer)

	notification_manager = get_node("/root/ModLoader/JLannoo-DesveladoAP/NotificationManager")

	timer.one_shot = true
	timer.connect("timeout", _on_trap_done)

func trigger_trap(duration: float = 0.0):
	if is_active:
		return

	is_active = true

	if effect:
		effect.call()

	_notify(duration)

	timer.start(duration)

	trap_triggered.emit()

func _on_trap_done():
	is_active = false

	if undo_effect:
		undo_effect.call()

	trap_done.emit()
	queue_free()

func _notify(duration: float):
	var text = "You have been %s-ed" % [notification_manager.wrap_text_with_color(name, Color.MAGENTA)]

	if duration:
		text += " for %s seconds" % [notification_manager.wrap_text_with_color(str(duration), Color.YELLOW)]

	notification_manager.notify(text)

func effect():
	pass

func undo_effect():
	pass
