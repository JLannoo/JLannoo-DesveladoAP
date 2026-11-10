extends "res://Levels/Components/bonus_collectable.gd"

const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")
const NetworkItem = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ap_files/network_item.gd")

const AP_ICON = preload("res://mods-unpacked/JLannoo-DesveladoAP/resources/ap-logo.png")

func collect():
    # The id is not set properly in bone 7, breaking our numbering
    if id == -1:
        id = 7

    super()

    if not AP.instance.is_ap_connected(): return
    
    AP.instance.collect_location(id)

func reset(room_number: int):
    super(room_number)

    if not AP.instance.is_ap_connected(): return

    AP.instance.conn.scout(id, 0, func(item: NetworkItem):
        if not item.is_local():
            sprite.texture = AP_ICON
    )
