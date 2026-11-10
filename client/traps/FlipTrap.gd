extends "res://mods-unpacked/JLannoo-DesveladoAP/traps/Trap.gd"

@onready var camera: Camera2D = get_node("/root/Level/Camera2D")

var zoom: Vector2

func _ready():
    name = "Flip Trap"
    super()

func effect():
    zoom = camera.zoom
    camera.zoom.y = -zoom.y

func undo_effect():
    camera.zoom = zoom