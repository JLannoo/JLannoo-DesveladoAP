extends "res://Levels/Components/switch.gd"

const UnlockableComponent = preload("res://mods-unpacked/JLannoo-DesveladoAP/UnlockableComponent.gd")

@onready var unlockable: UnlockableComponent = UnlockableComponent.new(
	"Ghost Switch Unlock" 
	if scene_file_path.ends_with("switch_ghost.tscn") 
	else "Key Switch Unlock"
)

func _ready():
	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()

func _on_area_player_body_entered(body):
	if not unlockable.is_enabled: return
	super(body)
