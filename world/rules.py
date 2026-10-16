from __future__ import annotations

from typing import TYPE_CHECKING

from rule_builder.options import OptionFilter
from rule_builder.rules import Has, HasAll, Rule

if TYPE_CHECKING:
    from .world import DesveladoWorld

HAS_KEY = Has("Key")  # Hmm, what could this be? A little foreshadowing perhaps? :) You'll find out if you keep reading!


def set_all_rules(world: DesveladoWorld) -> None:
    # In order for AP to generate an item layout that is actually possible for the player to complete,
    # we need to define rules for our Entrances and Locations.
    # Note: Regions do not have rules, the Entrances connecting them do!
    # We'll do entrances first, then locations, and then finally we set our victory condition.

    set_completion_condition(world)


def set_completion_condition(world: DesveladoWorld) -> None:
    # Finally, we need to set a completion condition for our world, defining what the player needs to win the game.
    # For this, we can use world.set_completion_rule.
    # You can just set a completion condition directly like any other condition, referencing items the player receives:
    world.set_completion_rule(HasAll("Good"))

    # In our case, we went for the Victory event design pattern (see create_events() in locations.py).
    # So lets undo what we just did, and instead set the completion condition to:
    # world.set_completion_rule(Has("Victory"))


# One final comment about rules:
# If your world exclusively uses Rule Builder rules (like APQuest), it's worth trying CachedRuleBuilderWorld.
# CachedRuleBuilderWorld is a subclass of World that has a bunch of caching magic to make rules faster.
# Just have your world class subclass CachedRuleBuilderWorld instead of World:
#   class DesveladoWorld(CachedRuleBuilderWorld): ...
# This may speed up your world, or it may make it slower.
# The exact factors are complex and not well understood, but there is no harm in trying it.
# Generate a few seeds and see if there is a noticeable difference!
# If you're wondering, author has checked: APQuest is too simple to see any benefits, so we'll stick with "World".