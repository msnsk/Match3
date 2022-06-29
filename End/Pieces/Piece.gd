extends Node2D


export (String) var color

var matched = false

onready var sprite = $Sprite


func move(target):
	position = target


func make_matched():
	matched = true
	sprite.modulate = Color(1,1,1,.5)
