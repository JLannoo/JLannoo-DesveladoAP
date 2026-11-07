class_name Trap
extends Node2D

signal trap_triggered
signal trap_done

var is_active: bool = false
var timer: Timer = Timer.new()

var effect: Callable
var undo_effect: Callable

var notification_manager: CanvasLayer

func _ready():
	add_child(timer)

	timer.one_shot = true
	timer.connect("timeout", _on_trap_done)

func trigger_trap(duration: float):
	if is_active:
		return

	is_active = true

	if effect:
		effect.call()

	timer.start(duration)

	notification_manager.notify("You have been %s-ed for %s seconds!" % [
			notification_manager.wrap_text_with_color(name, Color.MAGENTA),
			notification_manager.wrap_text_with_color(str(duration), Color.YELLOW)
		])

	trap_triggered.emit()

func _on_trap_done():
	is_active = false

	if undo_effect:
		undo_effect.call()

	trap_done.emit()
	queue_free()
