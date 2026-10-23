import Utils
from test.bases import WorldTestBase

class MyGameTestBase(WorldTestBase):
    game = "Desvelado"

    def test_generate_graph(self) -> None:
        Utils.visualize_regions(self.world.multiworld.get_region("Map", 1), "worlds/desvelado/out.puml", show_entrance_names=True, show_locations=True, show_other_regions=True)
        self.assertTrue(True)