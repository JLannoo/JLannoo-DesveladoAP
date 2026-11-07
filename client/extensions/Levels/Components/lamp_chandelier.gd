extends "res://Levels/Components/lamp_chandelier.gd"

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Chandelier Unlock")

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()
