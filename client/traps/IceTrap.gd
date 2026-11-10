extends "res://mods-unpacked/JLannoo-DesveladoAP/traps/Trap.gd"

@onready var player: Player = get_node("/root/Level/Player")

func _ready():
    name = "Ice Trap"
    super()

func effect():
    if not player: return

    player.anim_tree.active = false
    GameManager.input_enabled = false
    player.modulate = Color(0, 1, 1)

    player.died.connect(func (): 
        # In case the player dies, disable controls again after short wait.
        await get_tree().create_timer(1).timeout
        print("==== Player DIED ====")
        GameManager.input_enabled = false
    )


func undo_effect():
    if not player: return
    
    player.anim_tree.active = true
    GameManager.input_enabled = true
    player.modulate = Color(1, 1, 1)