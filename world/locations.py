from __future__ import annotations

import logging
from typing import TYPE_CHECKING, List

from BaseClasses import ItemClassification, Location
from worlds.kdl3.names import location_name

from . import items

if TYPE_CHECKING:
    from .world import DesveladoWorld

def _map_stages_to_array():
    rooms = []

    for name, n in STAGE_ROOM_QUANTITY_MAP.items():
        display_name = name.replace("_", " ")
        for i in range(n):
            rooms.append(f"{display_name} - Room {i+1}")

    return rooms

STAGE_ROOM_QUANTITY_MAP = {
    "Castle_1": 34,
    "Castle_2": 22,

    "Sewers_1": 18,
    "Sewers_2": 21,
    "Sewers_3": 21,

    "Caves_1":  27,
    "Caves_2":  22,
    "Caves_3":  17,
}

ROOMS: List[str] = _map_stages_to_array()


BONNIE_BONES = [
    f"Bonnie Bone {i+1}" for i in range(items.BONNIE_BONES_AMOUNT)
]

MAP_PICKUPS = [
    f"Map Pickup {i+1}" for i in range(8)
]

ALL_LOCATIONS = ROOMS + BONNIE_BONES + MAP_PICKUPS

LOCATION_NAME_TO_ID = {
    name: i+1 for i, name in enumerate(ALL_LOCATIONS)
}

class DesveladoLocation(Location):
    game = "Desvelado"

def get_location_names_with_ids(location_names: list[str]) -> dict[str, int | None]:
    return {location_name: LOCATION_NAME_TO_ID[location_name] for location_name in location_names}


def create_all_locations(world: DesveladoWorld) -> None:
    create_regular_locations(world)
    create_events(world)


def create_regular_locations(world: DesveladoWorld) -> None:
    castle_1 = world.get_region("Castle 1")

    castle_1.add_locations(LOCATION_NAME_TO_ID)


def create_events(world: DesveladoWorld) -> None:
    castle_1 = world.get_region("Castle 1")

    castle_1.add_event("Completed Final Room", "Victory", location_type=DesveladoLocation, item_type=items.DesveladoItem)
