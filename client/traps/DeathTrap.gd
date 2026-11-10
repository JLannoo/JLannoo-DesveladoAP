extends "res://mods-unpacked/JLannoo-DesveladoAP/traps/Trap.gd"

func _ready():
    name = "Death Trap"
    super()

func effect():
    var player = get_node("/root/Level/Player")
    if not player: return

    player.die(true)
