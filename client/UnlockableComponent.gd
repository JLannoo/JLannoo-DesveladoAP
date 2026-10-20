class_name UnlockableComponent
extends Node2D

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
		Archipelago.connected.connect(_on_ap_connection)
	

func _on_ap_connection(_conn: ConnectionInfo = null, _json: Dictionary = {}) -> bool:
	if not Archipelago.is_ap_connected(): return false

	if not Archipelago.conn.received_items.any(func (item: NetworkItem): 
		return _get_ap_item_name(item.id) == needed_item
	):
		is_enabled = false

	if not Archipelago.conn.obtained_item.is_connected(_on_item_arrive):
		Archipelago.conn.obtained_item.connect(_on_item_arrive)
	return true

func _get_ap_item_name(id: int) -> String:
	return Archipelago.conn.get_gamedata_for_player().get_item_name(id)

func _on_item_arrive(item: NetworkItem):
	if _get_ap_item_name(item.id) == needed_item:
		is_enabled = true
		
func dim_when_locked(target: CanvasItem, unlockable: UnlockableComponent) -> void:
		var apply = func(enabled): 
			target.modulate.a = 1.0 if enabled else opacity_dim
			
		unlockable.state_changed.connect(apply)
		apply.call(unlockable.is_enabled)
