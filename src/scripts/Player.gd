extends KinematicBody2D

# when true, prints coords
export var DEBUG := true

# all the journal page names
var PAGES = ["j1", "j2", "j3", "j4"]

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

# teleport vars
var first_teleport  := false
var second_teleport := false
var third_teleport  := false
var forth_teleport  := false

# journal related vars
var current_journal := -1
var reading         := false

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
		disable_dot() # turns off the stamina dot
		speed = speed * 2 # adjusts movement speed
		dashing = true
		
	if Input.is_action_just_pressed("walk") and not dashing:
		speed = speed / 2
	elif Input.is_action_just_released("walk"):
		speed = base_speed
		
	# animate the player sprite
	animate(direction, speed)
	
	# only dash for a certain period of time
	if dashing:
		dash_time -= 1
	
	# once dash time is over, reset speed and start cooldown
	if dash_time == 0:
		speed = base_speed
		dash_time = base_dash_time
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
	
	if journal_number == 3 and not third_teleport:
		global_position.x += 3072
		third_teleport = true
	elif journal_number == 4 and not forth_teleport:
		global_position.y += 0
		forth_teleport = true
	elif journal_number == 5:
		pass

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
	print("dupe entered")
	get_parent().get_node("journal_3_dupe/interact").visible = true
	current_journal = 3

func _on_journal3_dupe_body_exited(body):
	get_parent().get_node("journal_3_dupe/interact").visible = false
	print("dupe exited")
	current_journal = 0
	
func _on_journal4_body_entered(body):
	get_parent().get_node("journal_4/interact").visible = true
	current_journal = 4
	
func _on_journal4_body_exited(body):
	get_parent().get_node("journal_4/interact").visible = false
	current_journal = 0
	
# --- end signal handling ----------------------------------------------------------------------

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
	
	if speed < base_speed:	
		sprite.speed_scale = 0.5
	elif speed > base_speed:
		sprite.speed_scale = 1.5
	else:
		sprite.speed_scale = 1.0

# there is no end to the shame pit
