extends KinematicBody2D

export var base_speed := 175
export var base_dash_time := 50
export var base_dash_cooldown := 200

var dash_time := base_dash_time
var dash_cooldown := base_dash_cooldown

var dashing := false
var cooling_down := false
var speed := base_speed

func _physics_process(delta) -> void:
	var direction := calculate_move_direction()
	
	if Input.is_action_just_pressed("dash") and not dashing:
		toggle_dot()
		speed = speed * 3
		dashing = true
	
	if dashing:
		dash_time -= 1
	
	if dash_time <= 0:
		speed = base_speed
		cooling_down = true
		dashing = false
	
	if cooling_down:
		dash_cooldown -= 1
		if (dash_cooldown <= 0):
			toggle_dot()
			cooling_down = false
			dash_cooldown = base_dash_cooldown
			dash_time = base_dash_time
		
	move_and_slide(direction * speed)
	
func toggle_dot():
	get_node("dash").visible = not get_node("dash").visible
	
func calculate_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
