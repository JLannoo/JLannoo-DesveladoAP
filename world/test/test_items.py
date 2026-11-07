from BaseClasses import ItemClassification

from .bases import DesveladoTestBase
from .. import items


def pool_names(test: DesveladoTestBase) -> list[str]:
    return [item.name for item in test.multiworld.itempool]


def trap_names() -> list[str]:
    return [trap.name for trap in items.TRAPS]


class TestItemPool(DesveladoTestBase):
    def test_base_items_are_added_once(self) -> None:
        names = pool_names(self)
        for item in items.BASE_ITEM_DATA:
            self.assertEqual(names.count(item.name), 1, item.name)

    def test_every_bone_is_in_pool(self) -> None:
        self.assertEqual(pool_names(self).count("Bonnie Bone"), items.BONNIE_BONES_AMOUNT)

    def test_bones_are_filler_on_finish_goal(self) -> None:
        for bone in self.get_items_by_name("Bonnie Bone"):
            self.assertEqual(bone.classification, ItemClassification.filler)


class TestBonesProgressionOnBonnieGoal(DesveladoTestBase):
    options = {"goal": "bonnie"}

    def test_bones_are_progression(self) -> None:
        for bone in self.get_items_by_name("Bonnie Bone"):
            self.assertTrue(bone.advancement)


class TestTrapsDisabled(DesveladoTestBase):
    options = {"traps": False, "trap_filler_percentage": 100}

    def test_no_traps_in_pool(self) -> None:
        names = pool_names(self)
        for trap in trap_names():
            self.assertNotIn(trap, names)


class TestAllFillerAreTraps(DesveladoTestBase):
    options = {"traps": True, "trap_filler_percentage": 100}

    def test_no_nothing_items_in_pool(self) -> None:
        self.assertNotIn("Nothing!", pool_names(self))


class TestSingleTrapWeight(DesveladoTestBase):
    options = {
        "traps": True,
        "trap_filler_percentage": 100,
        "trap_death_weight": "high",
        "trap_ice_weight": "none",
        "trap_flip_weight": "none",
        "trap_blind_weight": "none",
        "trap_relight_weight": "none",
        "trap_confusion_weight": "none",
    }

    def test_only_weighted_trap_in_pool(self) -> None:
        names = pool_names(self)
        self.assertIn("Death Trap", names)
        for trap in trap_names():
            if trap != "Death Trap":
                self.assertNotIn(trap, names)


class TestAllTrapWeightsNone(DesveladoTestBase):
    options = {
        "traps": True,
        "trap_filler_percentage": 100,
        "trap_death_weight": "none",
        "trap_ice_weight": "none",
        "trap_flip_weight": "none",
        "trap_blind_weight": "none",
        "trap_relight_weight": "none",
        "trap_confusion_weight": "none",
    }

    def test_filler_falls_back_to_nothing(self) -> None:
        names = pool_names(self)
        self.assertIn("Nothing!", names)
        for trap in trap_names():
            self.assertNotIn(trap, names)
