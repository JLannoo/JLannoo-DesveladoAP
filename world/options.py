from dataclasses import dataclass

from Options import Choice, OptionGroup, PerGameCommonOptions, Range, Toggle

class TestToggle(Toggle):
    auto_display_name="Test toggle"

class TestRange(Range):
    auto_display_name="Test range"

@dataclass
class DesveladoOptions(PerGameCommonOptions):
    toggle: TestToggle
    range: TestRange
