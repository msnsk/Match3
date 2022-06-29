extends Node2D


onready var anim_playser = $AnimationPlayer

func _ready():
	anim_playser.play("display_coin")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "display_coin":
		queue_free()
