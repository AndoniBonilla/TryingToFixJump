class_name PlayerStateFall extends PlayerState

@export var fall_gravity_multiplier : float = 1.165
@export var coyote_time : float = 0.125
@export var jump_buffer_time : float = 0.125
@export var peak_fall_speed : float = 0.0


var coyote_timer : float = 0
var buffer_timer : float = 0

#what happens when the state is initialized?
func init() -> void:
	
	pass
	
#what happens when we enter this state?
func enter() -> void:
	#Play animation
	# Making sure that the fall speed isn't set to any value
	peak_fall_speed = 0.0
	player.animation_player.play( "Jump" )
	player.animation_player.pause()
	player.gravity_multiplier = fall_gravity_multiplier
	if player.previous_state == jump:
		coyote_timer = 0
	else:
		coyote_timer = coyote_time
	pass
	
#what happens when we exit this state?
func exit() -> void:
	player.gravity_multiplier = 1.0
	buffer_timer = 0
	# Printing the fall speed of Silas, in order to determine how the range of where the animation
	# should be playing
	print("Peak fall speed this fall: ", peak_fall_speed)
	pass

	

#what happens when an input is pressed?
func handle_input(_event : InputEvent) -> PlayerState:
	if _event.is_action_pressed("jump"):
		if coyote_timer > 0:
			return jump 
		else:
			buffer_timer = jump_buffer_time
	return next_state
	
#what happens each process tick of this state?
func process(_delta: float) -> PlayerState:
	coyote_timer -= _delta
	buffer_timer -= _delta

	set_jump_frame()
	
	return next_state
	
#what happens each physics_process tick of this state?
func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		if buffer_timer > 0:
			return jump
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	# This checks a range between the peak_fall_speed and the player's velocity and returns 
	# whichever of the two is higher
	peak_fall_speed = maxf(peak_fall_speed, player.velocity.y)

	return next_state
# Creating a boolean variable to check that a player cannot press the fall animation if they
# are on the ground

		
func set_jump_frame() -> void:
	var frame : float = clampf(remap(player.velocity.y, 0.0, 
	player.max_fall_velocity, 1.0, 2.0), 1.0, 2.0)
	
	player.animation_player.seek(frame, true)
	pass
