extends "res://Levels/Components/lamp_inert.gd"

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Progressive Map")

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()

func _on_player_entered(body):
	if not unlockable.is_enabled: return
	super(body)
