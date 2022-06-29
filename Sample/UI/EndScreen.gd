extends ColorRect


onready var score_label = $VBoxContainer/ScoreContainer/ScoreLabel
onready var coin_label = $VBoxContainer/CoinContainer/CoinLabel
onready var final_score_label = $FinalScoreLabel
onready var button_sound = $ButtonSound


func reflect_score(score, coin, final_score):
	score_label.text = str(score)
	coin_label.text = str(coin)
	final_score_label.text = str(final_score)


func _on_RestartButton_pressed():
	button_sound.play()
	get_tree().paused = false
	yield(button_sound, "finished")
	get_tree().call_deferred("change_scene", "res://Game/Game.tscn")

