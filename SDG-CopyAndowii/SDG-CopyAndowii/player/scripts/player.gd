class_name Player extends CharacterBody2D
# Player script contains all the states that the character
# will be in. With this, there are some methods that each of
# these states will have:

# handle_input
# process_function
# phyiscs_process_function

#region / on-ready variables
# $Sprite is the relative path of the character's sprite 2D


# Here is a variable named sprite that holds 
# the character sprite
@onready var sprite: Sprite2D = $Sprite2D
# This is one of two collision shapes that deal with the 
# player. In this case, it acts the collision box 
# for when the player is standing/running

@onready var collision_stand: CollisionShape2D = $CollisionStand



# This variable holds a one way shape cast, which scans 
# underneath a region of space. Note: it is more 
# computationally heavy and should not be used for a lot
# of platforms. Use a ray cast instead because it is a 
# straight line versus this is a full body. 
@onready var one_way_platform_shape_cast: ShapeCast2D = $OneWayPlatformShapeCast
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#endregion
# Added random comment

#region / export variables
# @export exposes these as editable fields in the Godot Inspector
@export var move_speed : float = 900
@export var jump_velocity : float = 1000
@export var max_fall_velocity : float = 600.0
@onready var drop_timer : Timer = $Timer
#endregion
#region / state machine variables
# Hold each player state in an arrray
var states : Array[PlayerState]
var current_state : PlayerState :
	get : return states.front()
	# previous state is the 
var previous_state : PlayerState :
	get : return states[ 1 ]
#endregion

#region / standard variables
# This vector starts the direction at 0
var direction : Vector2 = Vector2.ZERO
# This is a constant that describes the gravity that acts on the player,
# this determines how floaty a player is
var gravity : float = 800
# This is a multipler for how heavy the gravity will act on the player
var gravity_multiplier : float = 1.5
#endregion

func drop_through() -> void:
	# If the timer is still running, we're already mid-drop,
	# so don't start another one
	if !(drop_timer.is_stopped()):   
		return
	# Turn off mask layer 2 (One Way Platform) 
	# so the player stops colliding with one-way platforms and falls through.
	set_collision_mask_value(2, false)  
	# Start the drop timer (length set by Wait Time in the Inspector). When it
	# finishes, _on_timer_timeout() turns mask layer 2 back on."
	drop_timer.start()                   
	
func can_drop_through() -> bool:
	if  !is_on_floor():
			# Returning a false statement whenever 
			return false
	one_way_platform_shape_cast.force_shapecast_update()
	# returns a boolean of whether the one way plat is colliding with the 
	# player or
	return one_way_platform_shape_cast.is_colliding()
		
# Chaning the collision layer to the layer that deals with one way platforms
func _on_timer_timeout() -> void:
	set_collision_mask_value(2, true)    
	
	
func _ready() -> void:
	# This connects the timer for the one way plat collision and the 
	# function that allows for the one way platform to collide with players
	drop_timer.timeout.connect(_on_timer_timeout)
	# Creates the player's states
	initialize_states()

	pass
# Changes the state based on 
func _unhandled_input(event: InputEvent) -> void:
	change_state( current_state.handle_input( event ))
	pass

func _process(_delta: float) -> void:
	update_direction()
	change_state( current_state.process( _delta ))
	pass

func _physics_process(_delta: float) -> void:
	velocity.y += gravity * _delta * gravity_multiplier
	velocity.y = clampf(velocity.y, -10000.0, max_fall_velocity)
	move_and_slide()
	change_state( current_state.physics_process( _delta ))
	pass
# 
func initialize_states() -> void:
	#Create an empty array to hold the states
	states = []
	#gather all states
	for c in $States.get_children():
		# if the random value c is a playerState, add the
		# current state to the array of states
		
		if c is PlayerState:
			states.append( c )
			c.player = self
		pass
	# If there are no states, then exit out of the function
	if states.size() == 0:
		return
	
	#initialize all states
	for state in states:
		# Run the state's init function
		state.init()
		
	#set our first state
	change_state( current_state )
	# Run the current state's enter function
	current_state.enter()
	# Track the current state's name in a label
	$Label.text = current_state.name
	pass
	
# Pass to a new state, if the new state is null, leave the current state and 
# print out a debug log 
# state that we just added. If null, exit out of the program
# Returns a PlayerState
func change_state( new_state : PlayerState) -> void:
	if new_state == null:
		await get_tree().create_timer(60.0).timeout
		print("Null state")
		return
	elif new_state == current_state:
		return
	# 
	# This is the one that will be running all of the states
	# If in this state, use the exit function of that state 
	# and run it 
	if current_state:
		current_state.exit()
		
		
	# Adds the new state to the front of the array
	# array, making it the current state
	states.push_front( new_state )
	# Call the enter function of the current state
	current_state.enter()
	# Change the array size to 3 to limit how many states 
	# there can be at any given time
	states.resize( 3 )
	# Keep a label that holds the current state's name. 
	# This name is then going to be displayed, above the
	# player 
	$Label.text = current_state.name
	pass
	
func update_direction() -> void:
	# Updates what the previous direction is based on what the current 
	# direction is
	var prev_direction : Vector2 = direction
	var x_axis = Input.get_axis("left", "right")
	var y_axis = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)
	if prev_direction.x != direction.x:
		if direction.x < 0:
			# Allows for the sprite to be flipped
			sprite.flip_h = true
	
		elif direction.x > 0:
			sprite.flip_h = false
		
	pass
