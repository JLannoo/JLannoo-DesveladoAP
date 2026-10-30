extends "res://Levels/Components/bonus_collectable.gd"

const AP_ICON = preload("res://mods-unpacked/JLannoo-DesveladoAP/resources/ap-logo.png")

func collect():
    # The id is not set properly in bone 7, breaking our numbering
    if id == -1:
        id = 7

    super()

    if not Archipelago.is_ap_connected(): return
    
    Archipelago.collect_location(id)

func reset(room_number: int):
    super(room_number)

    if not Archipelago.is_ap_connected(): return

    Archipelago.conn.scout(id, 0, func(item: NetworkItem):
        if not item.is_local():
            sprite.texture = AP_ICON
    )
