extends "res://mods-unpacked/JLannoo-DesveladoAP/traps/Trap.gd"
const BlindOverlay = preload("res://mods-unpacked/JLannoo-DesveladoAP/ui/blind_overlay.gd")


@onready var camera: Camera2D = get_node("/root/Level/Camera2D")
@onready var player: Player = get_node("/root/Level/Player")

@onready var overlay: BlindOverlay = load("res://mods-unpacked/JLannoo-DesveladoAP/ui/blind_overlay.tscn").instantiate()

var camera_offset = Vector2(1920/2.0, 1080/2.0)

func get_player_screen_position():
	return player.position-(camera.position - camera_offset)

func _ready():
	name = "Blind Trap"

	super()

func _process(_delta: float):
	overlay.material.set("shader_parameter/position", get_player_screen_position())

func effect():
	camera.add_child(overlay)
	overlay.appear()

func undo_effect():
	overlay.disappear()
