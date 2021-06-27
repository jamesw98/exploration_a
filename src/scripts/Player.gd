extends KinematicBody2D

# when true, prints coords
export var DEBUG := true

# all the journal page names
var PAGES := ["j1", "j2", "j3", "j4", "j5", "j6", "j7"]

# speed related vars
export var base_speed         := 200
export var base_dash_time     := 50
export var base_dash_cooldown := 200

# cooldown related times
var dash_time     := base_dash_time
var dash_cooldown := base_dash_cooldown

# dash related bools
var dashing      := false
var cooling_down := false

# speed related vars
var speed := base_speed

# whether or player is walking
var walking := false

# teleport vars
var first_teleport  := false
var second_teleport := false
var third_teleport  := false
var forth_teleport  := false

# journal related vars
var current_journal := -1
var reading         := false

# variables for this stage's puzzle
var puzzle_started := false 
var dummy_5        := false # for the dummy journal 5 in puzzle room 3
var read_j6        := false 
var read_j7        := false
var correct_order  := false
var puzzle_index   := -1    # helps determine where the player should currently be

# sprite info
onready var sprite := get_node("player_anim")

# runs every frame
func _physics_process(delta) -> void:
	var direction = Vector2.ZERO
	
	# don't allow the player to move while reading a journal
	if not reading:
		# get the direction to move
		direction = calculate_move_direction()
		
	# checks if there is teleportation to be done
	check_teleport(direction)
	
	# if the player is in range to read a journal, check to see if they interact
	if current_journal > 0:
		check_journal()
	
	# if the dash button is pressed, and the player isn't already dashing, start dashing
	if Input.is_action_just_pressed("dash") and not dashing:
		# turns off the stamina dot
		disable_dot() 
		speed = base_speed * 2 
		dashing = true
	# if the users holds space or ctrl, they will reduce their speed
	elif Input.is_action_just_pressed("walk") and not dashing:
		speed = base_speed / 2
		walking = true
	# if the users lets go of space or ctrl, their speed will go back to normal
	elif Input.is_action_just_released("walk"):
		speed = base_speed
		walking = false
		
	# animate the player sprite
	animate(direction, speed)
	
	# only dash for a certain period of time
	if dashing:
		dash_time -= 1
	
	# once dash time is over, reset speed and start cooldown
	if dash_time == 0:
		dash_time = 1
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

# checks if a player wants to read a journal page
func check_journal():
	# if the player presses 'e' and they aren't already reading, show the page
	if Input.is_action_just_pressed("interact") and not reading:
		show_journal(current_journal)
		reading = true
	# if the player presses 'e' and they are reading, close the page
	elif Input.is_action_just_pressed("interact") and reading:
		close_journal(current_journal)
		reading = false

# teleportation for spooky(tm) hallways and rooms
# sadly, there are lots of magic numbers in this function
# TODO change this to just be collision rectangles
func check_teleport(direction):
	if DEBUG:
		print(global_position)
	
	# initial hallway
	if global_position.x >= 1190 and not first_teleport:
		global_position.y += 1024
		first_teleport = true
	
	# second hallway
	elif (global_position.x > 1040 and global_position.x < 1090 \
		  and 1640 < global_position.y and global_position.y < 1750 \
		  and not second_teleport):
		global_position.y -= 608
		second_teleport = true

# show a journal page
func show_journal(journal_number):
	get_node("page_flip").play()
	get_node(PAGES[journal_number - 1]).visible = true
	get_node("close_message").visible = true
	
# close a journal page
func close_journal(journal_number):
	get_node("page_flip_close").play()
	get_node(PAGES[journal_number - 1]).visible = false
	get_node("close_message").visible = false
	
	print(dummy_5)
	
	# used to set up some of the set pieces
	if journal_number == 3 and not third_teleport:
		global_position.x += 3072
		third_teleport = true
	elif journal_number == 4 and not forth_teleport:
		global_position.x += 1120
		forth_teleport = true
	elif journal_number == 5 and not dummy_5:
		puzzle_index += 1
		# changes the current state of the puzzle
		check_puzzle(puzzle_index)
	elif journal_number == 6:
		read_j6 = true
		if not read_j7:
			correct_order = true
	elif journal_number == 7:
		read_j7 = true
	
func check_puzzle(index):
	if read_j6 and read_j7:
		print("solved")
		if correct_order:
			global_position.y += 2080
		else:
			global_position.y += 5600
	elif puzzle_index % 4 == 0:
		print("0")
		global_position.y += 992
	elif puzzle_index % 4 == 1:
		print("1")
		global_position.y += 1184
	elif puzzle_index % 4 == 2:
		print("2")
		global_position.y += 2336
	# go back to original room
	elif puzzle_index % 4 == 3:
		print("3")
		global_position.y -= 4512
	
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

# --- begin signal handling --------------------------------------------------------------------
func _on_infinite_hallway_body_entered(body):
	if body.get_name() == "Player":
		if dashing or not walking:
			global_position.x -= 64
			
func _on_journal1_body_entered(body):
	get_parent().get_node("journal_1/interact").visible = true
	current_journal = 1

func _on_journal1_body_exited(body):
	get_parent().get_node("journal_1/interact").visible = false
	current_journal = 0

func _on_journal2_body_entered(body):
	get_parent().get_node("journal_2/interact").visible = true
	current_journal = 2

func _on_journal2_body_exited(body):
	get_parent().get_node("journal_2/interact").visible = false
	current_journal = 0
	
func _on_journal3_body_entered(body):
	get_parent().get_node("journal_3/interact").visible = true
	current_journal = 3

func _on_journal3_body_exited(body):
	get_parent().get_node("journal_3/interact").visible = false
	current_journal = 0
	
func _on_journal3_dupe_body_entered(body):
	get_parent().get_node("journal_3_dupe/interact").visible = true
	current_journal = 3

func _on_journal3_dupe_body_exited(body):
	get_parent().get_node("journal_3_dupe/interact").visible = false
	current_journal = 0
	
func _on_journal4_body_entered(body):
	get_parent().get_node("journal_4/interact").visible = true
	current_journal = 4
	
func _on_journal4_body_exited(body):
	get_parent().get_node("journal_4/interact").visible = false
	current_journal = 0
	
func _on_journal5_body_entered(body):
	get_parent().get_node("journal_5/interact").visible = true
	get_parent().get_node("journal_5_hall/interact").visible = true
	get_parent().get_node("journal_5_updown/interact").visible = true
	get_parent().get_node("journal_5_deadend/interact").visible = true
	current_journal = 5
	
func _on_journal5_body_exited(body):
	get_parent().get_node("journal_5/interact").visible = false
	get_parent().get_node("journal_5_hall/interact").visible = false
	get_parent().get_node("journal_5_updown/interact").visible = false
	get_parent().get_node("journal_5_deadend/interact").visible = false
	current_journal = 0
	dummy_5 = false
	
func _on_journal5_dummy_body_entered(body):
	get_parent().get_node("journal_5_dummy/interact").visible = true
	current_journal = 5
	dummy_5 = true
	
func _on_journal5_dummy_body_exited(body):
	get_parent().get_node("journal_5_dummy/interact").visible = false
	current_journal = 0
	dummy_5 = false
	
func _on_journal6_body_entered(body):
	get_parent().get_node("journal_6/interact").visible = true
	current_journal = 6
	
func _on_journal6_body_exited(body):
	get_parent().get_node("journal_6/interact").visible = false
	current_journal = 0

func _on_journal7_body_entered(body):
	get_parent().get_node("journal_7/interact").visible = true
	current_journal = 7
	
func _on_journal7_body_exited(body):
	get_parent().get_node("journal_7/interact").visible = false
	current_journal = 0	
	
# --- begin shame pit --------------------------------------------------------------------------
# ugly, ugly code, used to animate the character sprite
func animate(direction: Vector2, speed: int):
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
	
	# adjust the sprite movement speed
	# sneaking
	if speed < base_speed:	
		sprite.speed_scale = 0.5
	# dashing
	elif speed > base_speed:
		sprite.speed_scale = 1.5
	# walking
	else:
		sprite.speed_scale = 1.0

# there is no end to the shame pit



