@tool extends VBoxContainer
const BaseConsole = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ui/console/base_console.gd")
const TypingBar = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ui/typing_bar.gd")


@export_group("Nodes")
@export var console_cont: Container
@export var console: BaseConsole
@export var typing_bar: TypingBar
@export var margin: MarginContainer
