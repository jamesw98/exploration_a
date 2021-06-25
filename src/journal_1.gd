extends Area2D

func body_enter(body):
	if body.is_in_group("player"):
		print("ouch!")
