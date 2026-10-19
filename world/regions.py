from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import Entrance, Region

if TYPE_CHECKING:
    from .world import DesveladoWorld
    
def create_and_connect_regions(world: DesveladoWorld) -> None:
    create_all_regions(world)


def create_all_regions(world: DesveladoWorld) -> None:
    castle_1 = Region("Castle 1", world.player, world.multiworld)
    castle_2 = Region("Castle 2", world.player, world.multiworld)

    sewers_1 = Region("Sewers 1", world.player, world.multiworld)
    sewers_2 = Region("Sewers 2", world.player, world.multiworld)
    sewers_3 = Region("Sewers 3", world.player, world.multiworld)

    caves_1 = Region("Caves 1", world.player, world.multiworld)
    caves_2 = Region("Caves 2", world.player, world.multiworld)
    caves_3 = Region("Caves 3", world.player, world.multiworld)

    regions = [castle_1, castle_2, sewers_1, sewers_2, sewers_3, caves_1, caves_2, caves_3]

    world.multiworld.regions += regions

