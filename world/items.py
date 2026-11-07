from __future__ import annotations

from enum import IntEnum, auto
from typing import TYPE_CHECKING, Final, List, NamedTuple

from BaseClasses import Item, ItemClassification

from . import options as desvelado_options

if TYPE_CHECKING:
    from .world import DesveladoWorld

BONNIE_BONES_AMOUNT: Final[int] = 15

class DesveladoItem(Item):
    game = "Desvelado"

class DesveladoItemData(NamedTuple):
    name: str
    type: ItemType
    id_in_type: int
    classification: ItemClassification = ItemClassification.progression

class ItemType(IntEnum):
    map_part = auto()
    unlock = auto()
    collectable = auto()
    filler = auto()
    trap = auto()

ITEM_TYPE_OFFSET_TABLE: dict[ItemType, int] = {
    ItemType.map_part:      1,
    ItemType.unlock:        100,
    ItemType.collectable:   200,
    ItemType.filler:        300,
    ItemType.trap:          400,
}

MAP_ITEMS: List[DesveladoItemData] = [
    DesveladoItemData("Castle 1 Map Part", ItemType.map_part, 0),
    DesveladoItemData("Castle 2 Map Part", ItemType.map_part, 1),

    DesveladoItemData("Sewers 1 Map Part", ItemType.map_part, 2),
    DesveladoItemData("Sewers 2 Map Part", ItemType.map_part, 3),
    DesveladoItemData("Sewers 3 Map Part", ItemType.map_part, 4),

    DesveladoItemData("Caves 1 Map Part", ItemType.map_part, 5),
    DesveladoItemData("Caves 2 Map Part", ItemType.map_part, 6),
    DesveladoItemData("Caves 3 Map Part", ItemType.map_part, 7),

    DesveladoItemData("Sewers Boss Map Part", ItemType.map_part, 8),
    DesveladoItemData("Castle Boss Map Part", ItemType.map_part, 9),
    DesveladoItemData("Caves Boss Map Part", ItemType.map_part, 10),
]

UNLOCK_ITEMS: List[DesveladoItemData] = [
    DesveladoItemData("Key Switch Unlock", ItemType.unlock, 0),
    DesveladoItemData("Ghost Switch Unlock", ItemType.unlock, 1),
    DesveladoItemData("Falling Platforms Unlock", ItemType.unlock, 2),
    DesveladoItemData("Ghost Walls Unlock", ItemType.unlock, 3),
    DesveladoItemData("Chandeliers Unlock", ItemType.unlock, 4),
]

UNLOCK_ITEMS_MAP: dict[str, str] = {
    "key_switch": "Key Switch Unlock",
    "ghost_switch": "Ghost Switch Unlock",
    "falling_platform": "Falling Platforms Unlock",
    "ghost_wall": "Ghost Walls Unlock",
    "chandelier": "Chandeliers Unlock",
}

BONNIE_ITEMS: List[DesveladoItemData] = [
    DesveladoItemData("Bonnie Bone", ItemType.collectable, 0, ItemClassification.filler)
]

FILLER: List[DesveladoItemData] = [
    DesveladoItemData("Nothing!", ItemType.filler, 0, ItemClassification.filler)
]

TRAPS: List[DesveladoItemData] = [
    DesveladoItemData("Death Trap",     ItemType.trap, 0, ItemClassification.trap), # Kills the player
    DesveladoItemData("Ice Trap",       ItemType.trap, 1, ItemClassification.trap), # Freezes the player in place for a few seconds
    DesveladoItemData("Flip Trap",      ItemType.trap, 2, ItemClassification.trap), # Flips the game upside down for a few seconds
    DesveladoItemData("Blind Trap",     ItemType.trap, 3, ItemClassification.trap), # Blinds the player for a few seconds
    DesveladoItemData("Relight Trap",   ItemType.trap, 5, ItemClassification.trap), # Relights all the torches in the room
    DesveladoItemData("Confusion Trap", ItemType.trap, 4, ItemClassification.trap), # Reverses the player's controls for a few seconds
]

BASE_ITEM_DATA: List[DesveladoItemData] = MAP_ITEMS + UNLOCK_ITEMS
ALL_ITEM_DATA: List[DesveladoItemData]  = MAP_ITEMS + UNLOCK_ITEMS + BONNIE_ITEMS + FILLER + TRAPS

def create_random_filler_item(world: DesveladoWorld):
    # If traps enabled, create them with corresponding chance and weights.
    if world.options.traps.value:
        trap_chance = world.options.trap_filler_percentage.value

        if world.multiworld.random.randint(1, 100) <= trap_chance:
            trap_weights = {
                "Death Trap": world.options.trap_death_weight.value,
                "Ice Trap": world.options.trap_ice_weight.value,
                "Flip Trap": world.options.trap_flip_weight.value,
                "Blind Trap": world.options.trap_blind_weight.value,
                "Relight Trap": world.options.trap_relight_weight.value,
                "Confusion Trap": world.options.trap_confusion_weight.value,
            }

            traps = []
            for trap_name, weight in trap_weights.items():
                traps.extend([trap_name] * weight)

            if traps:
                trap_name = world.multiworld.random.choice(traps)
                return world.create_item(trap_name)

    return world.create_item("Nothing!")

def get_item_classification(world: DesveladoWorld, item: DesveladoItemData) -> ItemClassification:
    if item.name == "Bonnie Bone" and world.options.goal == desvelado_options.Goal.option_bonnie:
        return ItemClassification.progression_skip_balancing

    return item.classification

def create_all_items(world: DesveladoWorld):
    # Base items
    itempool: List[Item] = [
        world.create_item(item.name) for item in BASE_ITEM_DATA
    ]

    # Collectables
    itempool += [world.create_item("Bonnie Bone") for _ in range(BONNIE_BONES_AMOUNT)]

    number_of_items = len(itempool)

    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    needed_number_of_filler_items = number_of_unfilled_locations - number_of_items

    itempool += [world.create_filler() for _ in range(needed_number_of_filler_items)]

    world.multiworld.itempool += itempool

## ID table looks like:
## Map Parts:     1   + id
## Unlocks:       100 + id
## Collectables:  200 + id
## Filler:        300 + id
## Traps:         400 + id
def generate_item_table() -> dict[str, int]:
    table = {}

    for item in ALL_ITEM_DATA:
        table[item.name] = ITEM_TYPE_OFFSET_TABLE[item.type] + item.id_in_type

    return table

ITEM_NAME_TO_ID = generate_item_table()

def get_item_by_name(world: DesveladoWorld, name: str) -> DesveladoItem:
    return next(DesveladoItem(item.name, get_item_classification(world, item), ITEM_NAME_TO_ID[item.name], world.player) for item in ALL_ITEM_DATA if item.name == name)

def generate_item_name_groups() -> dict[str, set[str]]:
    groups = {
        "Map Parts": set(),
        "Unlocks": set(),
        "Bones": set(),
    }

    for item in ALL_ITEM_DATA:
        if item.type == ItemType.map_part:
            groups["Map Parts"].add(item.name)
        elif item.type == ItemType.unlock:
            groups["Unlocks"].add(item.name)
        elif item.type == ItemType.collectable:
            groups["Bones"].add(item.name)

    return groups
