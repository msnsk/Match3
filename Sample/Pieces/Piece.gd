extends Node2D

export (String) var color
export (Texture) var square_face

var matched = false
var point = 0

onready var sprite = $Sprite
onready var tween = $Tween
onready var spawn_sound = $SpawnSound
onready var match_sound = $MatchSound


func _ready():
	spawn_sound.play()

func move(target):
	tween.interpolate_property(self, "position", position, target, .5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()


func make_matched():
	matched = true
#	sprite.modulate = Color(1,1,1,.5)
	sprite.texture = square_face
	match_sound.play()
