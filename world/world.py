from collections.abc import Mapping
from typing import Any

from worlds.AutoWorld import World

from . import items, locations, regions, rules, web_world
from . import options as desvelado_options 

class DesveladoWorld(World):
    game = "Desvelado"

    web = web_world.DesveladoWebWorld()

    options_dataclass = desvelado_options.DesveladoOptions
    options: desvelado_options.DesveladoOptions

    location_name_to_id = locations.LOCATION_NAME_TO_ID
    item_name_to_id = items.ITEM_NAME_TO_ID

    origin_region_name = "Castle 1"

    def create_regions(self) -> None:
        regions.create_and_connect_regions(self)
        locations.create_all_locations(self)

    def set_rules(self) -> None:
        rules.set_all_rules(self)

    def create_items(self) -> None:
        items.create_all_items(self)

    def create_item(self, name: str) -> items.DesveladoItem:
        return items.get_item_by_name(self, name)

    def get_filler_item_name(self) -> str:
        return items.create_random_filler_item(self).name
