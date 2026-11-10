extends "res://Levels/Components/collectable_notification.gd"

const AP = preload("res://mods-unpacked/JLannoo-DesveladoAP/godot_ap/autoloads/archipelago.gd")

enum ICONS { BONE, SKULL, AP }

const BONE_ICON = preload("res://Art/Sprites/Collectables/collectable_icon_bone.png")
const SKULL_ICON  = preload("res://Art/Sprites/Collectables/collectable_skull.png")
const AP_ICON    = preload("res://mods-unpacked/JLannoo-DesveladoAP/resources/ap-logo.png")

const ICON_MAP: Dictionary = {
	ICONS.BONE: BONE_ICON,
	ICONS.SKULL: SKULL_ICON,
	ICONS.AP: AP_ICON
}

var regular_override
var no_right_margin_override

func _ready():
	regular_override = $Notification.get_theme_stylebox("normal").duplicate()
	no_right_margin_override = regular_override.duplicate()
	no_right_margin_override.content_margin_right = -1

	# Don't pause notification when game is paused
	$Notification.process_mode = Node.PROCESS_MODE_ALWAYS
	
	super()

func show_message(text: String, counter: String = "", icon: ICONS = ICONS.AP) -> void:
	for child in $Notification/Icon.get_children():
		child.hide()
		
	var sprite: Sprite2D = $Notification/Icon/Skull  # reuse the skull sprite, swap its texture
	sprite.texture = ICON_MAP[icon]
	sprite.show()

	if not counter:
		$Notification.add_theme_stylebox_override("normal", no_right_margin_override)
	else:
		$Notification.add_theme_stylebox_override("normal", regular_override)

	$Notification.text = text
	$Notification/Counter.visible = counter != ""
	$Notification/Counter.text = counter

	anim_player.play("show")
	$Timer.start()
