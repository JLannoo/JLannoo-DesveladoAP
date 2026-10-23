from __future__ import annotations

import json
import logging
from typing import TYPE_CHECKING, overload

from BaseClasses import Entrance, Region
from rule_builder.rules import Has, HasAll

from . import room_data, locations, items

if TYPE_CHECKING:
    from .world import DesveladoWorld

LEVELS_DISPLAY_NAME = {
    "ZONA1_1": "Castle 1",
    "ZONA1_2": "Castle 2",
    "RUN_1":   "Castle Run",

    "ZONA2_1": "Sewers 1",
    "ZONA2_2": "Sewers 2",
    "ZONA2_3": "Sewers 3",
    "RUN_2":   "Sewers Run",

    "ZONA3_1": "Caves 1",
    "ZONA3_2": "Caves 2",
    "ZONA3_3": "Caves 3",
    "RUN_3":   "Caves Run",
}

def get_level_map_part_name(level_name: str):
    name = LEVELS_DISPLAY_NAME[level_name]
    if name is None: 
        return ""
    
    return f"{name} Map Part"

def get_required_map_parts_names(data: list[room_data.DesveladoLevelData], level_name: str) -> list[str]:
    required_levels = [data[id] for id in next(level.necessary_levels for level in data if level.name == level_name) ]
    required_maps = [get_level_map_part_name(level.name) for level in required_levels]

    return required_maps

def get_region_display_name(
    level: room_data.DesveladoLevelData | str,
    room: room_data.DesveladoRoomData | str,
) -> str:
    level_name = level.name if isinstance(level, room_data.DesveladoLevelData) else level
    room_name = room.name if isinstance(room, room_data.DesveladoRoomData) else room
    return f"{LEVELS_DISPLAY_NAME.get(level_name, level_name)} - {room_name}"

def get_connection_display_name(conn: room_data.DesveladoRoomConnection, level: room_data.DesveladoLevelData):
    return f"{level.name} - {conn.source_room} to {conn.dest_room}"


def create_and_connect_regions(world: DesveladoWorld) -> None:
    data = room_data.load_room_data()

    create_all_regions_and_locations(world, data)
    connect_regions(world, data)
    create_map_connections(world, data)
    create_events(world)


def create_all_regions_and_locations(world: DesveladoWorld, data: list[room_data.DesveladoLevelData]) -> None:
    regions: list[Region] = []

    for level in data:
        for room in level.rooms:
            region = Region(get_region_display_name(level, room), world.player, world.multiworld)
            locs: dict[str, int] = {}
            
            for location in room.locations:
                loc_name = f"{region.name} - {locations.LOCATION_TYPE_DISPLAY_NAME[location.type]}"
                loc_id = locations.LOCATIONS_TO_ID[loc_name]

                locs[loc_name] = loc_id

            region.add_locations(locs)

            regions.append(region)

    world.multiworld.regions += regions


def connect_regions(world: DesveladoWorld, data: list[room_data.DesveladoLevelData]):
    regions = world.get_regions()

    for level in data:
        for conn in level.room_connections:
            source_name = get_region_display_name(level, conn.source_room)
            dest_name   = get_region_display_name(level, conn.dest_room)

            source_region = next((r for r in regions if r.name == source_name), None)
            dest_region   = next((r for r in regions if r.name == dest_name), None)

            if source_region is None or dest_region is None:
                logging.error(f"Could not find some of the regions for connection {conn}")
                continue

            source_region.connect(dest_region, get_connection_display_name(conn, level))


def create_map_connections(world: DesveladoWorld, data: list[room_data.DesveladoLevelData]):
    map_region = Region("Map", world.player, world.multiworld)

    level1_1_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA1_1'], "Room_00"))
    level1_2_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA1_2'], "Room_48"))
    level2_1_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA2_1'], "Room_00"))
    level2_2_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA2_2'], "Room_57"))
    level2_3_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA2_3'], "Room_59"))
    level3_1_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA3_1'], "Room_01"))
    level3_2_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA3_2'], "Room_65"))
    level3_3_start = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA3_3'], "Room_39"))

    map_region.connect(level1_1_start, f"Map to {level1_1_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA1_1')))
    map_region.connect(level1_2_start, f"Map to {level1_2_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA1_2')))
    map_region.connect(level2_1_start, f"Map to {level2_1_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA2_1')))
    map_region.connect(level2_2_start, f"Map to {level2_2_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA2_2')))
    map_region.connect(level2_3_start, f"Map to {level2_3_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA2_3')))
    map_region.connect(level3_1_start, f"Map to {level3_1_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA3_1')))
    map_region.connect(level3_2_start, f"Map to {level3_2_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA3_2')))
    map_region.connect(level3_3_start, f"Map to {level3_3_start.name}", HasAll(*get_required_map_parts_names(data, 'ZONA3_3')))

    world.multiworld.regions += [map_region]

def create_events(world: DesveladoWorld):
    final_region = world.get_region(get_region_display_name(LEVELS_DISPLAY_NAME['ZONA3_3'], "Room_56"))
    final_region.add_event("Victory", "Victory", location_type=locations.DesveladoLocation, item_type=items.DesveladoItem)