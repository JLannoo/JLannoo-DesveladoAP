extends Node2D

const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")

const ConnectionInfo = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ap_files/connection_info.gd")
const NetworkItem = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ap_files/network_item.gd")
const UnlockableComponent = preload("res://mods-unpacked/JLannoo-DesveladoAP/UnlockableComponent.gd")

## Class meant to be used alongside a level component.
## Adds `is_enabled` property, defaulting to false until a specific
## Archipelago item is received.

@export var opacity_dim: float = 0.2

signal state_changed(enabled: bool)

var needed_item: String
var is_enabled: bool = true:
	set(value):
		is_enabled = value
		state_changed.emit(value)

func _init(item_name: String):
	needed_item = item_name
	name = "Unlockable Component"

	if not _on_ap_connection():
		AP.instance.connected.connect(_on_ap_connection)
	

func _on_ap_connection(_conn: ConnectionInfo = null, _json: Dictionary = {}) -> bool:
	if not AP.instance.is_ap_connected(): return false

	if not AP.instance.conn.received_items.any(func (item: NetworkItem): 
		return item.get_name() == needed_item
	):
		is_enabled = false

	if not AP.instance.conn.obtained_item.is_connected(_on_item_arrive):
		AP.instance.conn.obtained_item.connect(_on_item_arrive)
	return true

func _on_item_arrive(item: NetworkItem):
	if item.get_name() == needed_item:
		is_enabled = true
	

func dim_when_locked(target: CanvasItem, unlockable: UnlockableComponent) -> void:
		var apply = func(enabled): 
			target.modulate.a = 1.0 if enabled else opacity_dim
			
		unlockable.state_changed.connect(apply)
		apply.call(unlockable.is_enabled)
