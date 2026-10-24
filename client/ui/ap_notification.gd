extends "res://Levels/Components/collectable_notification.gd"

const AP_LOGO = preload("res://mods-unpacked/JLannoo-DesveladoAP/resources/ap-logo.png")

var regular_override
var no_right_margin_override

func _ready():
	regular_override = $Notification.get_theme_stylebox("normal").duplicate()
	no_right_margin_override = regular_override.duplicate()
	no_right_margin_override.content_margin_right = -1
	
	super()

func show_message(text: String, counter: String = "", icon: Texture2D = AP_LOGO) -> void:
	for child in $Notification/Icon.get_children():
		child.hide()
		
	var sprite: Sprite2D = $Notification/Icon/Skull  # reuse the skull sprite, swap its texture
	sprite.texture = icon
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
