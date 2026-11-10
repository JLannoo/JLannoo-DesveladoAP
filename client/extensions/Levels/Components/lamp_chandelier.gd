extends "res://Levels/Components/lamp_chandelier.gd"

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Chandeliers Unlock")

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()
