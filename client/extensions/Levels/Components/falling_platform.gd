extends "res://Levels/Components/falling_platform.gd"

const FIXED_SHADER = preload("res://mods-unpacked/JLannoo-DesveladoAP/extensions/Resources/Shaders/falling_platform.gdshader")

@onready var unlockable: UnlockableComponent = UnlockableComponent.new("Falling Platforms Unlock")

func _ready():
	# Shared ShaderMaterial; swapping its shader fixes every platform.
	# Swap is needed because original didn't respect modulate's alpha.
	if sprite.material is ShaderMaterial:
		sprite.material.shader = FIXED_SHADER

	add_child(unlockable)
	unlockable.dim_when_locked(self, unlockable)

	super()

func _on_trigger_area_2d_body_entered(body):
	if not unlockable.is_enabled: return
	super(body)
