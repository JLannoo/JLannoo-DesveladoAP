extends "res://Engine/game_manager.gd"

# We hook into this instead of directly bonus_collectable.collect
# because when stage_manager is extended (high in the inheritance tree)
# it preloads the bonus_collectable scene before its extended
func add_collectable(id: int):
    super(id)

    # Bones are first in the location id list
    print("Collecting %s" % id)
    Archipelago.collect_location(id)