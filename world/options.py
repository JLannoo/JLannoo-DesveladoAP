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
    """Enables Deathlink for this world. If enabled, when a player dies in this world, all other players with Deathlink enabled will also die."""
    display_name="Deathlink"
    default = False

class DeathlinkAmnesty(Range):
    """Sets the number of deaths that need to occur in this world before a deathlink is sent to other players. Only applies if Deathlink is enabled."""
    display_name="Deathlink Amnesty"
    range_start = 0
    range_end = 20
    default = 5

class Traps(Toggle):
    """Enables Traps for this world. If enabled, some items will be traps that will hinder the player in some way."""
    display_name="Traps"
    default = True

class TrapFillerPercentage(Range):
    """Sets the percentage of traps in the filler item pool. Only applies if Traps are enabled."""
    range_start = 0
    range_end = 100
    default = 10
    display_name="Trap Filler Percentage"

class TrapBaseWeight(Choice):
    """Sets the base weight of traps in the item pool. Only applies if Traps are enabled."""
    display_name="Trap Base Weight"
    option_none = 0
    option_low = 1
    option_medium = 2
    option_high = 3
    default = 2

class TrapDeathWeight(TrapBaseWeight):
    """
    Sets the weight of Death Traps in the item pool.

    Death Traps kill the player instantly.
    """
    display_name="Death Trap weight"

class TrapIceWeight(TrapBaseWeight):
    """
    Sets the weight of Ice Traps in the item pool.

    Ice Traps freeze the player in place for a few seconds.
    """
    display_name="Ice Trap weight"

class TrapFlipWeight(TrapBaseWeight):
    """
    Sets the weight of Flip Traps in the item pool.

    Flip Traps turn the screen upside down for a few seconds.
    """
    display_name="Flip Trap weight"

class TrapBlindWeight(TrapBaseWeight):
    """
    Sets the weight of Blind Traps in the item pool.

    Blind Traps prevent the player from seeing the screen.
    """
    display_name="Blind Trap weight"

class TrapRelightWeight(TrapBaseWeight):
    """
    Sets the weight of Relight Traps in the item pool.

    Relight Traps turn an already turned-off lamp back on.
    """
    display_name="Relight Trap weight"

class TrapConfusionWeight(TrapBaseWeight):
    """
    Sets the weight of Confusion Traps in the item pool.

    Confusion Traps mix up the player's controls.
    """
    display_name="Confusion Trap weight"


desvelado_option_groups = [
    OptionGroup("Goal", [Goal]),
    OptionGroup("Deathlink", [Deathlink, DeathlinkAmnesty]),
    OptionGroup("Traps", [Traps, TrapFillerPercentage, TrapDeathWeight, TrapIceWeight, TrapFlipWeight, TrapBlindWeight, TrapRelightWeight, TrapConfusionWeight]),
]

@dataclass
class DesveladoOptions(PerGameCommonOptions):
    goal: Goal
    
    deathlink: Deathlink
    deathlink_amnesty: DeathlinkAmnesty

    traps: Traps
    trap_filler_percentage: TrapFillerPercentage
    trap_death_weight: TrapDeathWeight
    trap_ice_weight: TrapIceWeight
    trap_flip_weight: TrapFlipWeight
    trap_blind_weight: TrapBlindWeight
    trap_relight_weight: TrapRelightWeight
    trap_confusion_weight: TrapConfusionWeight