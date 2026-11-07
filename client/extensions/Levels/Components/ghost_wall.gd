extends "res://Levels/Components/ghost_wall.gd"

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Ghost Walls Unlock")

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()

func _on_check_dash_area_enter(body):
	if not unlockable.is_enabled and body is Player:
		# Expire dash's physics calculations with big delta
		body.fsm.states.dash.physics_process(100000)
		return

	super(body)
