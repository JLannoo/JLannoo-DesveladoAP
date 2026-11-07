from BaseClasses import CollectionState

from .bases import DesveladoTestBase
from .. import items, regions, room_data


class TestFinishGoal(DesveladoTestBase):
    def test_not_beatable_with_nothing(self) -> None:
        self.assertBeatable(False)

    def test_bones_not_required(self) -> None:
        self.collect_all_but("Bonnie Bone")
        self.assertBeatable(True)

    def test_not_beatable_with_only_map_parts(self) -> None:
        self.collect_by_name([item.name for item in items.MAP_ITEMS])
        self.assertBeatable(False)


class TestBonnieGoal(DesveladoTestBase):
    options = {"goal": "bonnie"}

    def test_requires_every_bone(self) -> None:
        self.collect_all_but("Bonnie Bone")
        bones = self.get_items_by_name("Bonnie Bone")

        self.collect(bones[:-1])
        self.assertBeatable(False)

        self.collect(bones[-1])
        self.assertBeatable(True)


class TestBonnieGoalAllTraps(DesveladoTestBase):
    options = {"goal": "bonnie", "traps": True, "trap_filler_percentage": 100}


class TestMinimalAccessibility(DesveladoTestBase):
    options = {"accessibility": "minimal"}


class TestMapAccess(DesveladoTestBase):
    def state_with(self, item_names: list[str]) -> CollectionState:
        state = CollectionState(self.multiworld)
        for name in item_names:
            state.collect(self.world.create_item(name), True)
        return state

    def test_every_level_has_a_region(self) -> None:
        data = room_data.load_room_data()
        self.assertEqual(len(self.world.get_region("Map").exits), len(data))

    def test_teleports_require_exact_map_parts(self) -> None:
        data = room_data.load_room_data()
        display_to_level = {display: name for name, display in regions.LEVELS_DISPLAY_NAME.items()}

        for entrance in self.world.get_region("Map").exits:
            if entrance.connected_region:
                level_name = display_to_level[entrance.connected_region.name.split(" - ")[0]]
                required = regions.get_required_map_parts_names(data, level_name)

                with self.subTest(entrance=entrance.name):
                    self.assertTrue(entrance.can_reach(self.state_with(required)))

                    for missing in required:
                        remaining = [name for name in required if name != missing]
                        self.assertFalse(entrance.can_reach(self.state_with(remaining)), f"Reachable without {missing}")
            else:
                self.fail(f"Entrance {entrance.name} is not connected to a region")


class TestMechanicGates(DesveladoTestBase):
    def state_with(self, item_names: list[str]) -> CollectionState:
        state = CollectionState(self.multiworld)
        for name in item_names:
            state.collect(self.world.create_item(name), True)
        return state

    def test_connections_require_source_room_mechanics(self) -> None:
        for level in room_data.load_room_data():
            mechanics_by_room = {room.name: room.mechanics for room in level.rooms}

            for conn in level.room_connections:
                entrance = self.world.get_entrance(regions.get_connection_display_name(conn, level))
                required = [items.UNLOCK_ITEMS_MAP[mechanic] for mechanic in mechanics_by_room[conn.source_room]]

                with self.subTest(entrance=entrance.name):
                    self.assertTrue(entrance.access_rule(self.state_with(required)))

                    for missing in required:
                        remaining = [name for name in required if name != missing]
                        self.assertFalse(entrance.access_rule(self.state_with(remaining)), f"Passable without {missing}")

    def test_locations_require_room_mechanics(self) -> None:
        for level in room_data.load_room_data():
            for room in level.rooms:
                required = [items.UNLOCK_ITEMS_MAP[mechanic] for mechanic in room.mechanics]

                for location in self.world.get_region(regions.get_region_display_name(level, room)).locations:
                    with self.subTest(location=location.name):
                        self.assertTrue(location.access_rule(self.state_with(required)))

                        for missing in required:
                            remaining = [name for name in required if name != missing]
                            self.assertFalse(location.access_rule(self.state_with(remaining)), f"Checkable without {missing}")
