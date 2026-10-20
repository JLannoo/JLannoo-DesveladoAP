extends "res://Levels/Components/falling_platform.gd"

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Progressive Map")

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()

func _on_trigger_area_2d_body_entered(body):
	if not unlockable.is_enabled: return
	super(body)
