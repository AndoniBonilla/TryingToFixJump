class_name PlayerStateJump extends PlayerState


@export var jump_velocity : float = 450.0
#what happens when the state is initialized?
func init() -> void:
	pass
	
#what happens when we enter this state?
func enter() -> void:
	#Play animation
	player.animation_player.play( "Jump" )
	player.animation_player.pause()
	player.velocity.y = -player.jump_velocity
	pass
	
#what happens when we exit this state?
func exit() -> void:
	pass
	
#what happens when an input is pressed?
func handle_input(_event : InputEvent) -> PlayerState:
	if _event.is_action_released("jump"):
		player.velocity.y *= 0.5
	return next_state
	
#what happens each process tick of this state?
func process(_delta: float) -> PlayerState:
	set_jump_frame()
	return next_state
	
#what happens each physics_process tick of this state?
func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0:
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
	
	
func set_jump_frame() -> void:
	var frame : float = remap(player.velocity.y,-jump_velocity,0.0, 0.0, 1.0)
	player.animation_player.seek(frame, true)
	pass
