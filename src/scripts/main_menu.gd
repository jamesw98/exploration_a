extends Node2D

func _process(delta):
	pass

func _on_start_button_mouse_entered():
	get_node("Walls2").visible = true

func _on_start_button_mouse_exited():
	get_node("Walls2").visible = false

func _on_start_button_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		get_tree().change_scene("res://src/test_scene.tscn")
