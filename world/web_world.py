from BaseClasses import Tutorial
from worlds.AutoWorld import WebWorld

from . import options

class DesveladoWebWorld(WebWorld):
    game = "Desvelado"

    theme = "grassFlowers"

    setup_en = Tutorial(
        "Multiworld Setup Guide",
        "A guide to setting up Desvelado for MultiWorld.",
        "English",
        "setup_en.md",
        "setup/en",
        ["JLannoo"],
    )

    tutorials = [setup_en]

    option_groups = options.desvelado_option_groups