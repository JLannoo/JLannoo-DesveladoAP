extends MarginContainer
const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")
const ThemeBox = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/ui/theme_box.gd")


@export var themes: Array[ThemeBox]
@export var default_theme: ThemeBox

func _ready():
	for themebox in themes:
		themebox.set_theme.connect(set_console_theme)
		themebox.set_pressed_no_signal(themebox.target_theme_path == AP.instance.config.window_theme_path)
	if AP.instance.config.window_theme_path.is_empty():
		default_theme.set_pressed(true)
	else:
		refresh_console_theme()

func set_console_theme(path: String) -> void:
	if path.is_empty(): return
	var theme_res := load(path) as Theme
	if not theme_res: return
	get_window().theme = theme_res
	AP.instance.config.window_theme_path = path

func refresh_console_theme() -> void:
	set_console_theme(AP.instance.config.window_theme_path)
