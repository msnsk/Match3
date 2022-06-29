extends CanvasLayer

onready var timelabel = $Boards/TimeBoard/VBoxContainer/TimeLabel
onready var scorelabel = $Boards/ScoreBoard/VBoxContainer/ScoreLabel
onready var coinlabel = $Boards/CoinBoard/VBoxContainer/CoinLabel

func update_time(time):
	timelabel.text = str(time)

func update_score(score):
	scorelabel.text = str(score)
	
func update_coin(coin):
	coinlabel.text = str(coin)
