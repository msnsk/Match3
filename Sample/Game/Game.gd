extends Node2D

enum {
	READY
	PLAY
	TIMEUP
}

export var time: int = 30
var score: int = 0
var coin: int = 0
var state = READY

onready var ui = $UI
onready var grid = $Grid
onready var sign_screen = $Screens/SignScreen
onready var end_screen = $Screens/EndScreen
onready var sign_timer = $SignTimer
onready var play_timer = $PlayTimer


func _ready():
	grid.connect("piece_deleted", self, "_on_Grid_piece_deleted")
	grid.connect("combo_stopped", self, "_on_Grid_combo_stopped")
	grid.connect("waiting_started", self, "_on_Grid_waiting_started")
	grid.connect("waiting_finished", self, "_on_Grid_waiting_finished")
	ui.update_time(time)
	ui.update_score(score)
	ui.update_coin(coin)
	end_screen.hide()
	sign_screen.show()
	sign_timer.start()


func _on_SignTimer_timeout():
	match state:
		READY:
			sign_screen.get_node("SignLabel").text = "Go!"
			state = PLAY
		PLAY:
			sign_timer.stop()
			sign_screen.hide()
			play_timer.start()
		TIMEUP:
			sign_screen.hide()
			var final_score = score * coin
			end_screen.reflect_score(score, coin, final_score)
			end_screen.show()


func _on_PlayTimer_timeout():
	if time > 0:
		time -= 1
		ui.update_time(time)
	else:
		play_timer.stop()
		state = TIMEUP
		get_tree().paused = true
		sign_screen.get_node("SignLabel").text = "Time\nUp!"
		sign_screen.show()
		sign_timer.start()


# Connected signal
func _on_Grid_piece_deleted(point):
	score += point
	ui.update_score(score)

# Connected signal
func _on_Grid_combo_stopped(combo):
	coin += combo
	ui.update_coin(coin)

# Connected signal
func _on_Grid_waiting_started():
	play_timer.paused = true

# Connected signal
func _on_Grid_waiting_finished():
	play_timer.paused = false
