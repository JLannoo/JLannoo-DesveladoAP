extends "res://Levels/Components/bonnie.gd"

const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")

@onready var mod_main = get_node("/root/ModLoader/JLannoo-DesveladoAP")
@onready var game_manager = get_node("/root/GameManager")

func _on_body_entered(body: PhysicsBody2D):
    super(body)

    if game_manager.count_collectables() == game_manager.TOTAL_COLLECTABLES and AP.instance.conn.slot_data.get("goal") == mod_main.GAME_GOAL.bonnie:
        mod_main.ap_send_goal()