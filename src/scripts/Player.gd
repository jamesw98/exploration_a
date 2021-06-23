extends KinematicBody2D

export var base_speed := 175
export var max_stamina := 200

var speed := base_speed
var stamina := max_stamina
var running := false
var out_of_stam := false

func _physics_process(delta) -> void:
	var direction := calculate_move_direction()
	
	if Input.is_action_just_pressed("run"):
		running = true
		speed *= 2
	elif Input.is_action_just_released("run") or out_of_stam:
		out_of_stam = false
		running = false
		speed = base_speed
		
	if (running):
		stamina -= 1
	elif (stamina < max_stamina): 
		stamina += 1
		
	print(stamina)
		
	if (stamina < 0):
		running = false
		out_of_stam = true
	
	move_and_slide(direction * speed)
	
func calculate_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
