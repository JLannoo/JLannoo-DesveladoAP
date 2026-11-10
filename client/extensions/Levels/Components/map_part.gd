extends "res://Levels/Components/map_part.gd"

const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")

# Always display map parts
func display():
    show()
    area_collision.disabled = false

func _on_area_2d_body_entered(body: Node2D):
    super(body)

    AP.instance.collect_location(100+StageManager.current_stage)