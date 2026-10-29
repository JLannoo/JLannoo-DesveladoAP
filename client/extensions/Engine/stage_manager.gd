extends "res://Engine/stage_manager.gd"

var ap_map_parts: Array[int] = []

func ap_add_map_part(stage: int) -> void:
    if stage in ap_map_parts: return
    ap_map_parts.append(stage)
    update_unlocked_states()

# Hijack checking stages finished state with custom ap_map_parts
func update_unlocked_states():
    if GameManager.is_demo or not current_stages_data: return
    for i in current_stages_data.stages.size():
            var stage = get_saved_stage(i)
            stage.unlocked = get_necessary_stages_finished(i) == stage.necessary_zones.size()

func get_necessary_stages_finished(stage):
    return get_saved_stage(stage).necessary_zones.filter(
        func(z): return z in ap_map_parts
    ).size()

func get_stage_won_state(stage: int):
    return stage in ap_map_parts
