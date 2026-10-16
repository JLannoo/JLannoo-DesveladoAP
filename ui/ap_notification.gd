extends "res://Levels/Components/collectable_notification.gd"

const AP_LOGO = preload("res://mods-unpacked/JLannoo-DesveladoAP/resources/ap-logo.png")

func show_message(text: String, counter: String = "", icon: Texture2D = AP_LOGO) -> void:
	for child in $Notification/Icon.get_children():
		child.hide()
		
	var sprite: Sprite2D = $Notification/Icon/Skull  # reuse the skull sprite, swap its texture
	sprite.texture = icon
	sprite.show()
	
	$Notification.text = text
	$Notification/Counter.visible = counter != ""
	$Notification/Counter.text = counter
	anim_player.play("show")
	$Timer.start()
