extends TextureRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func appear():
	animation_player.play("fade_in")

func disappear():
	animation_player.play("fade_in", -1, -1, true)
	await animation_player.animation_finished
	queue_free()
