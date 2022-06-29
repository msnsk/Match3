extends ColorRect


onready var button_sound = $ButtonSound


func _on_StartButton_pressed():
	button_sound.play()


func _on_ButtonSound_finished():
	get_tree().change_scene("res://Game/Game.tscn")
