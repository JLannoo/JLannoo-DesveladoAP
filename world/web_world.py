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

    setup_es = Tutorial(
        setup_en.tutorial_name,
        "Una guía para configurar Desvelado para MultiWorld.",
        "Español",
        "setup_es.md",
        "setup/es",
        ["JLannoo"],
    )

    tutorials = [setup_en, setup_es]

    game_info_languages = ["en", "es"]

    option_groups = options.desvelado_option_groups