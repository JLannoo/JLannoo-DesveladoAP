from __future__ import annotations

from typing import TYPE_CHECKING

from rule_builder.options import OptionFilter
from rule_builder.rules import Has

if TYPE_CHECKING:
    from .world import DesveladoWorld

def set_all_rules(world: DesveladoWorld) -> None:
    set_completion_condition(world)


def set_completion_condition(world: DesveladoWorld) -> None:
    world.set_completion_rule(Has("Victory"))
