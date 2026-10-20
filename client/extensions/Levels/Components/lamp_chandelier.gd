extends "res://Levels/Components/lamp_chandelier.gd"

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Progressive Map")

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()

func check_player_overlap():
	if not unlockable.is_enabled: return
	super()
