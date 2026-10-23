import json
import pkgutil
from enum import StrEnum

from dataclasses import dataclass

class LocationType(StrEnum):
    clear = "room_clear"
    bonus = "bonus_collectable"
    map   = "map_part"

@dataclass
class DesveladoRoomConnection:
    dest_room: str
    type: str
    source_room: str = ""
    start_open: bool = False

@dataclass
class DesveladoLocationData:
    name: str
    type: LocationType
    id: int | None = None

@dataclass
class DesveladoRoomData:
    index: int
    name: str
    is_bonus: bool
    is_branch: bool
    is_zone_end: bool
    mechanics: list[str]
    exits: list[DesveladoRoomConnection]
    locations: list[DesveladoLocationData]

@dataclass
class DesveladoLevelData:
    id: int
    name: str
    necessary_levels: list[int]
    room_connections: list[DesveladoRoomConnection]
    rooms: list[DesveladoRoomData]

def load_room_data() -> list[DesveladoLevelData]:
    try:
        data_file = pkgutil.get_data(__name__, "data/room_data.json")
        if data_file is None:
            raise Exception("There was a problem loading Desvelado's room_data.json. Please regenerate it with data/extract_room_data.gd")

        data = json.loads(data_file)

        levels = []

        for level in data["levels"]:
            room_connections = [DesveladoRoomConnection(**conn) for conn in level["room_connections"]]
            rooms = []

            for room in level["rooms"]:
                exits = [DesveladoRoomConnection(**exit) for exit in room["exits"]]
                locations = [DesveladoLocationData(**loc) for loc in room["locations"]]

                rooms.append(DesveladoRoomData(room["index"], room["name"], room["is_bonus"], room["is_branch"], room["is_zone_end"], room["mechanics"], exits, locations))

            levels.append(DesveladoLevelData(level["id"], level["name"], level["necessary_levels"], room_connections, rooms))

        return levels
            
    except IOError:
        raise Exception("Couldn't find Desvelado's data/room_data.json. If it was removed, please generate it using data/extract_room_data.gd")