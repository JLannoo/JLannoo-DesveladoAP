from __future__ import annotations

import logging
from typing import TYPE_CHECKING, List

from BaseClasses import Location

from . import room_data, regions
from .room_data import LocationType, DesveladoLevelData, DesveladoLocationData, DesveladoRoomData

if TYPE_CHECKING:
    from .world import DesveladoWorld

LOCATION_TYPE_DISPLAY_NAME: dict[LocationType, str] = {
    LocationType.clear: "Room Cleared",
    LocationType.bonus: "Bonnie Bone",
    LocationType.map:   "Map Part",
}

class DesveladoLocation(Location):
    game = "Desvelado"

def get_location_index(location: DesveladoLocationData, level: DesveladoLevelData, room: DesveladoRoomData):
    if location.type == LocationType.bonus and location.id:
        return (1 + location.id - 1)
    elif location.type == LocationType.map:
        return (100 + level.id)
    elif location.type == LocationType.clear:
        return (1000 + 100 * level.id + room.index)

    logging.error(f"Location {level.name} {room.name} {location.name} for Desvelado was generated with id -1 because it was not of a valid type.")
    return -1

## ID table looks like:
## Bones:  1    + bone_id-1 (1-15)
## Maps:   100  + level_id  (100-107)
## Clears: 1000 + 100 * level_id + room_index (max room_index ~65)
def generate_location_table() -> dict[str, int]:
    data = room_data.load_room_data()

    location_table: dict[str, int] = {}
    
    for level in data:
        for room in level.rooms:
            region_name = regions.get_region_display_name(level, room)
            
            for location in room.locations:
                loc_name = f"{region_name} - {LOCATION_TYPE_DISPLAY_NAME[location.type]}"
                loc_id = get_location_index(location, level, room)

                location_table[loc_name] = loc_id

    return location_table

LOCATIONS_TO_ID = generate_location_table()    
