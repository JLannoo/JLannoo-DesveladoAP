class_name DeathTrap
extends Trap

func _ready():
    name = "Death Trap"
    super()

func effect():
    var player = get_node("/root/Level/Player")
    if not player: return

    player.die(true)
