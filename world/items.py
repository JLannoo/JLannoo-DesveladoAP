from __future__ import annotations

from typing import TYPE_CHECKING, Final, List, NamedTuple

from BaseClasses import Item, ItemClassification

if TYPE_CHECKING:
    from .world import DesveladoWorld

BONNIE_BONES_AMOUNT: Final[int] = 15

class DesveladoItemData(NamedTuple):
    name: str
    classification: ItemClassification = ItemClassification.progression

MAP_ITEMS: List[DesveladoItemData] = [
    DesveladoItemData("Progressive Map")
]

class DesveladoItem(Item):
    game = "Desvelado"

UNLOCK_ITEMS: List[DesveladoItemData] = [
    DesveladoItemData("Chandeliers Unlock"),
    DesveladoItemData("Ghost Walls Unlock"),
    DesveladoItemData("Falling Platforms Unlock"),
    DesveladoItemData("Key Switch Unlock"),
    DesveladoItemData("Ghost Switch Unlock"),
]

BONNIE_ITEMS: List[DesveladoItemData] = [
    DesveladoItemData("Bonnie Bone", ItemClassification.filler)
] * BONNIE_BONES_AMOUNT

ALL_ITEM_DATA: List[DesveladoItemData] = MAP_ITEMS + UNLOCK_ITEMS + BONNIE_ITEMS

ITEM_NAME_TO_ID = {
    item.name: id+1 for id, item in enumerate(ALL_ITEM_DATA)
}

def create_random_filler_item(world: DesveladoWorld):
    return DesveladoItemData("Bonnie Bone", ItemClassification.filler)

def create_all_items(world: DesveladoWorld):
    itempool: List[Item] = [
        world.create_item(item.name) for item in ALL_ITEM_DATA
    ]

    number_of_items = len(itempool)

    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    needed_number_of_filler_items = number_of_unfilled_locations - number_of_items

    itempool += [world.create_filler() for _ in range(needed_number_of_filler_items)]

    world.multiworld.itempool += itempool

def get_item_by_name(world: DesveladoWorld, name: str) -> DesveladoItem:
    return next(DesveladoItem(item.name, item.classification, i, world.player) for i, item in enumerate(ALL_ITEM_DATA) if item.name == name)