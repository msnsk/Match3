extends Node2D


onready var stars = $Stars
onready var point_label = $PointLabelPos/PointLabel
onready var anim_player = $AnimationPlayer
onready var spawn_sound = $SpawnSound


func _ready():
	stars.emitting = true
	anim_player.play("display_point")
	spawn_sound.play()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "display_point":
		if spawn_sound.playing:
			yield(spawn_sound, "finished")
		queue_free()
