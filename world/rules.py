from __future__ import annotations

from typing import TYPE_CHECKING

from . import items, regions, room_data, options as desvelado_options

from rule_builder.options import OptionFilter
from rule_builder.rules import Has, HasAll

if TYPE_CHECKING:
    from .world import DesveladoWorld

def set_all_rules(world: DesveladoWorld) -> None:
    set_room_location_rules(world)
    set_completion_condition(world)


def set_room_location_rules(world: DesveladoWorld) -> None:
    for level in room_data.load_room_data():
        for room in level.rooms:
            if not room.mechanics:
                continue

            required_items = [items.UNLOCK_ITEMS_MAP[mechanic] for mechanic in room.mechanics]

            for location in world.get_region(regions.get_region_display_name(level, room)).locations:
                world.set_rule(location, HasAll(*required_items))


def set_completion_condition(world: DesveladoWorld) -> None:
    if world.options.goal == desvelado_options.Goal.option_bonnie:
        world.set_completion_rule(Has("Victory") & Has("Bonnie Bone", items.BONNIE_BONES_AMOUNT))
    else:
        world.set_completion_rule(Has("Victory"))