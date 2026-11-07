from dataclasses import dataclass

from Options import Choice, OptionGroup, PerGameCommonOptions, Range, Toggle

class Goal(Choice):
    """
    Sets the goal for this world. The goal is the objective that must be reached.
    
    Finish: The player must reach the end of the game.
    Bonnie: The player must have all 15 Bonnie bones and talk to Bonnie after reaching the end.
    """
    display_name = "Goal"
    option_finish = 1
    option_bonnie = 2
    default = 1

class Deathlink(Toggle):
    """Enables Deathlink for this world. If enabled, when a player dies in this world, all other players deathlink-enabled worlds will also die."""
    display_name="Deathlink"
    default = False

class DeathlinkAmnesty(Range):
    """Sets the number of deaths that need to occur in this world before a deathlink is sent to other players. Only applies if Deathlink is enabled."""
    display_name="Deathlink Amnesty"
    range_start = 0
    range_end = 20
    default = 5

class TestToggle(Toggle):
    """This is a test toggle"""
    auto_display_name="Test toggle"



desvelado_option_groups = [
    OptionGroup("Goal", [Goal]),
    OptionGroup("Deathlink", [Deathlink, DeathlinkAmnesty]),
]

@dataclass
class DesveladoOptions(PerGameCommonOptions):
    goal: Goal
    
    deathlink: Deathlink
    deathlink_amnesty: DeathlinkAmnesty
    toggle: TestToggle
    range: TestRange
