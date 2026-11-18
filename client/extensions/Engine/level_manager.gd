extends "res://Engine/level_manager.gd"

const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")

@onready var mod_main = get_node("/root/ModLoader/JLannoo-DesveladoAP")

func setup_room(_quick: bool = false):
    super()

    if AP.instance.is_ap_connected():
        if zone == StagesEnum.stage_names.BONNIE_ROOM and AP.instance.conn.slot_data.get("goal") == mod_main.GAME_GOAL.finish:
            mod_main.ap_send_goal()