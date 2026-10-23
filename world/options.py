from dataclasses import dataclass

from Options import Choice, OptionGroup, PerGameCommonOptions, Range, Toggle

class TestToggle(Toggle):
    """This is a test toggle"""
    auto_display_name="Test toggle"

class TestRange(Range):
    """This is a test range"""
    auto_display_name="Test range"

@dataclass
class DesveladoOptions(PerGameCommonOptions):
    toggle: TestToggle
    range: TestRange
