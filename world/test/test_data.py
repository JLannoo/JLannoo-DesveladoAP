import unittest

from .. import items, locations, regions, room_data
from ..room_data import LocationType


class TestRoomData(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.data = room_data.load_room_data()

    def all_locations(self) -> list[room_data.DesveladoLocationData]:
        return [location for level in self.data for room in level.rooms for location in room.locations]

    def test_level_ids_match_list_index(self) -> None:
        # get_required_map_parts_names indexes the level list by necessary_levels ids
        for index, level in enumerate(self.data):
            self.assertEqual(level.id, index, level.name)

    def test_every_level_has_display_name_and_map_part(self) -> None:
        for level in self.data:
            self.assertIn(level.name, regions.LEVELS_DISPLAY_NAME)
            self.assertIn(regions.get_level_map_part_name(level.name), items.ITEM_NAME_TO_ID)

    def test_connections_point_to_existing_rooms(self) -> None:
        # connect_regions only logs missing rooms, so generation would still succeed
        for level in self.data:
            room_names = {room.name for room in level.rooms}

            for conn in level.room_connections:
                self.assertIn(conn.source_room, room_names, level.name)
                self.assertIn(conn.dest_room, room_names, level.name)

    def test_location_ids_are_valid_and_unique(self) -> None:
        ids = list(locations.LOCATIONS_TO_ID.values())
        self.assertEqual(len(ids), len(set(ids)))
        self.assertNotIn(-1, ids)

    def test_bones_match_item_amount(self) -> None:
        bone_ids = sorted(location.id for location in self.all_locations() if location.type == LocationType.bonus) # type: ignore , id will always exist for bonus locations
        self.assertEqual(bone_ids, list(range(1, items.BONNIE_BONES_AMOUNT + 1)))
