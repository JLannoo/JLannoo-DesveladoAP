extends "res://Levels/Components/map_part.gd"

# Always display map parts
func display():
    show()
    area_collision.disabled = false

func _on_area_2d_body_entered(body: Node2D):
    super(body)

    Archipelago.collect_location(100+StageManager.current_stage)