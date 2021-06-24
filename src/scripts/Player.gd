extends KinematicBody2D

export var base_speed := 200
export var base_dash_time := 50
export var base_dash_cooldown := 200

var dash_time := base_dash_time
var dash_cooldown := base_dash_cooldown

var dashing := false
var cooling_down := false
var speed := base_speed

var first_teleport := false
var second_teleport := false

onready var sprite := get_node("player_anim")
var last_dir := "walk_right"

# runs every frame
func _physics_process(delta) -> void:
	# gets the direction the player is moving
	var direction := calculate_move_direction()
	
	# animate the player sprite
	animate(direction)

	check_teleport()
	
	# if the dash button is pressed, and the player isn't already dashing, start dashing
	if Input.is_action_just_pressed("dash") and not dashing:
		disable_dot() # turns off the stamina dot
		speed = speed * 2 # adjusts movement speed
		dashing = true
	
	if (Input.is_action_just_pressed("interact")):
		global_position.x = global_position.x + 100
	
	# only dash for a certain period of time
	if dashing:
		dash_time -= 1
	
	# once dash time is over, reset speed and start cooldown
	if dash_time <= 0:
		speed = base_speed
		cooling_down = true
		dashing = false
	
	# cooldown
	if cooling_down:
		dash_cooldown -= 1
		
		# once cooldown is over, renable dashing and turn the dot back on
		if (dash_cooldown <= 0):
			enable_dot()
			cooling_down = false
			# reset cooldowns and dash duration
			dash_cooldown = base_dash_cooldown
			dash_time = base_dash_time
			
	move_and_slide(direction * speed)

func check_teleport():
	print(global_position)
	
	var in_x = 1070 < global_position.x and global_position.x < 1040
	var in_y = 1640 < global_position.y and global_position.y < 1750
	
	# initial hallway
	if global_position.x >= 1190 and not first_teleport:
		global_position.y += 1024
		first_teleport = true
		
	elif (global_position.x > 1040 and global_position.x < 1090) and (1640 < global_position.y and global_position.y < 1750) and not second_teleport:
		global_position.y -= 608
		#global_position.x -= 250
		second_teleport = false


# ugly, ugly code, used to animate the character sprite
func animate(direction: Vector2):
	if direction.x > 0 and direction.y == 0:
		sprite.play("walk_right")	
	elif direction.x < 0 and direction.y == 0:
		sprite.play("walk_left")
	elif direction.x == 0 and direction.y > 0:
		sprite.play("walk_down")
	elif direction.x == 0 and direction.y < 0:
		sprite.play("walk_up")
	elif direction.x > 0 and direction.y > 0:
		sprite.play("walk_diag_down_right")
	elif direction.x < 0 and direction.y < 0:
		sprite.play("walk_diag_up_left")
	elif direction.x > 0 and direction.y < 0:
		sprite.play("walk_diag_up_right")
	elif direction.x < 0 and direction.y > 0:
		sprite.play("walk_diag_down_left")
	else:
		sprite.play("walk_down")
		sprite.stop()

# turns the dash dot off
func disable_dot():
	get_node("dash").visible = false
	
# turns the dash dot on
func enable_dot():
	get_node("dash").visible = true
	
# does what it says
func calculate_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
