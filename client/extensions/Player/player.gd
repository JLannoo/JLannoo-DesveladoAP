extends "res://Player/player.gd"

func lamp_in(lamp: Lamp) -> void:
	var uc = lamp.get("unlockable")
	if uc and not uc.is_enabled:
		return
	
	super(lamp)
