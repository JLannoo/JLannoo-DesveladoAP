extends "res://Levels/Components/switch.gd"

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Progressive Map")

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()

func _on_area_player_body_entered(body):
	if not unlockable.is_enabled: return
	super(body)
