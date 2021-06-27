extends Node2D

func _ready():
	$background_music.play(0)

func _on_background_music_finished():
	$background_music.play(0)
