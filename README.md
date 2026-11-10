# DesveladoAP

An [Archipelago](https://archipelago.gg) multiworld randomizer for
[Desvelado](https://store.steampowered.com/app/2878710/Desvelado/).

Core mechanics (switches, falling platforms, ghost walls, chandeliers) and each level's map part are shuffled into the
multiworld item pool. Clearing rooms, collecting Bonnie's bones and picking up map parts send checks to other players.
Optional traps and DeathLink are supported.

## Playing

### What you need
- Desvelado **v1.1.0** (Steam)
- [Godot Mod Loader](https://wiki.godotmodding.com/) **v7.0.1**
- [Archipelago](https://github.com/ArchipelagoMW/Archipelago/releases) **0.6.8+** (only needed to generate games)
- From the [latest release](https://github.com/JLannoo/JLannoo-DesveladoAP/releases):
  - `desvelado.apworld`: the world, used to generate the multiworld
  - `JLannoo-DesveladoAP.zip`: the game mod

### Quick start
1. **Install the apworld:** double-click `desvelado.apworld`, or copy it into Archipelago's `custom_worlds` folder.
2. **Make your options file:** in the Archipelago Launcher, open the `Options Creator`, select `Desvelado` in the left list and enter the options you want.
3. **Install the mod:** set up Godot Mod Loader for the game, create a `mods` folder next to the game executable and
   drop `JLannoo-DesveladoAP.zip` into it (don't extract it).
4. **Connect:** launch the game, open **Archipelago Console** from the main or pause menu, and enter the host, port,
   slot name and password.

The full guides are in [`world/docs`](world/docs):
[setup (EN)](world/docs/setup_en.md) · [setup (ES)](world/docs/setup_es.md) ·
[game info (EN)](world/docs/en_Desvelado.md) · [game info (ES)](world/docs/es_Desvelado.md)

### Reporting issues
Bugs and suggestions go in [GitHub issues](https://github.com/JLannoo/JLannoo-DesveladoAP/issues).
